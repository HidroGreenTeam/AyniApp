import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ayni/detection/services/plant_disease_classifier.dart';
import 'package:ayni/detection/services/hybrid_detection_service.dart';
import 'package:ayni/detection/services/detection_history_service.dart';
import 'package:ayni/detection/presentation/pages/detection_history_page.dart';
import 'package:ayni/detection/presentation/pages/detection_detail_page.dart';
import 'package:ayni/detection/data/models/detection_history_item.dart';
import '../widgets/initializing_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/processing_widget.dart';
import '../widgets/image_result_widget.dart';
import '../widgets/welcome_widget.dart';
import '../widgets/dialogs.dart';

class CameraPage extends StatefulWidget {
  final bool? detectionMode; // true = online, false = local, null = auto
  
  const CameraPage({super.key, this.detectionMode});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isInitializing = true;
  String? _initError;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _detectedDisease;
  double? _confidence;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  // Services
  final PlantDiseaseClassifier _classifier = PlantDiseaseClassifier();
  final HybridDetectionService _hybridService = HybridDetectionService();
  final DetectionHistoryService _historyService = DetectionHistoryService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeServices();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeServices() async {
    setState(() {
      _isInitializing = true;
      _initError = null;
    });
    
    try {
      debugPrint('Initializing detection services...');
      
      // Initialize hybrid service
      final hybridSuccess = await _hybridService.initialize();
      
      if (!hybridSuccess) {
        // Fallback to local classifier
        debugPrint('Hybrid service failed, falling back to local classifier...');
        final localSuccess = await _classifier.initialize();
        
        if (!localSuccess) {
          setState(() {
            _initError = 'Failed to initialize any detection service';
            _isInitializing = false;
          });
          
          if (mounted) {
            _showErrorSnackBar(
              'Failed to initialize detection services. Please try again.',
              action: SnackBarAction(
                label: 'Details',
                onPressed: () => CameraDialogs.showModelCompatibilityDialog(context, _initializeServices),
              ),
            );
          }
          return;
        }
      }
      
      setState(() {
        _isInitializing = false;
      });
      _fadeController.forward();
      debugPrint('Successfully initialized detection services');
      
    } catch (e) {
      debugPrint('Error initializing services: $e');
      
      setState(() {
        _initError = 'Error initializing: $e';
        _isInitializing = false;
      });
      
      if (mounted) {
        _showErrorSnackBar(
          'Error initializing: $e',
          action: SnackBarAction(
            label: 'Help',
            onPressed: () => CameraDialogs.showModelCompatibilityDialog(context, _initializeServices),
          ),
        );
      }
    }
  }

  void _showErrorSnackBar(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onError),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: action,
        duration: const Duration(seconds: 8),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isProcessing = true;
          _detectedDisease = null;
          _confidence = null;
        });
        await _runInference();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      setState(() {
        _isProcessing = false;
      });
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _runInference() async {
    if (_image == null) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      // Si estamos en modo diagnóstico (navegamos desde DiagnosePage), 
      // solo retornamos la imagen sin procesar
      if (Navigator.of(context).canPop()) {
        setState(() {
          _isProcessing = false;
        });
        
        // Retornar la imagen al DiagnosePage
        Navigator.of(context).pop(_image);
        return;
      }

      // Procesamiento normal para detección independiente
      if (_initError != null) {
        bool success = await _hybridService.initialize();
        if (!success) {
          setState(() {
            _isProcessing = false;
          });
          _showErrorSnackBar('Failed to initialize detection service. Please try again.');
          return;
        } else {
          setState(() {
            _initError = null;
          });
        }
      }

      DetectionResult? result;
      
      // Use detection mode based on widget parameter
      switch (widget.detectionMode) {
        case true: // Force online
          try {
            result = await _hybridService.detectOnlineOnly(_image!);
          } catch (e) {
            debugPrint('Online detection failed: $e');
            _showErrorSnackBar('Online detection failed. Please check your internet connection.');
            setState(() {
              _isProcessing = false;
            });
            return;
          }
          break;
          
        case false: // Force local
          result = await _hybridService.detectLocalOnly(_image!);
          break;
          
        default: // Auto (null)
          result = await _hybridService.detectDisease(_image!);
          break;
      }
      
      if (result == null) {
        setState(() {
          _isProcessing = false;
        });
        _showErrorSnackBar('Failed to analyze image. Please try with a different image.');
        return;
      }
      
      setState(() {
        _isProcessing = false;
        _detectedDisease = result!.disease;
        _confidence = result.confidence;
      });

      DetectionHistoryItem? savedItem;
      try {
        savedItem = await _historyService.saveDetection(
          disease: result.disease,
          diseaseName: result.formattedDiseaseName,
          confidence: result.confidence,
          imageFile: _image!,
          recommendation: result.recommendation,
        );
        _showSuccessSnackBar('Detection saved to history successfully');
      } catch (e) {
        debugPrint('Error saving to history: $e');
      }

      if (savedItem != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetectionDetailPage(detection: savedItem!),
          ),
        );
        return;
      }
      
      if (mounted) {
        CameraDialogs.showResultDialog(context, result.disease, result.confidence, result.recommendation);
      }
      
    } catch (e) {
      debugPrint('Error during inference: $e');
      setState(() {
        _isProcessing = false;
      });
      _showErrorSnackBar('Error analyzing image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Plant Disease Detection',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.history, size: 24, color: Theme.of(context).colorScheme.onPrimary),
              tooltip: 'Detection History',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetectionHistoryPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (_isInitializing)
                    InitializingWidget(
                      fadeAnimation: _fadeAnimation,
                      pulseAnimation: _pulseAnimation,
                    )
                  else if (_initError != null)
                    CameraErrorWidget(
                      errorMessage: _initError!,
                      onRetry: _initializeServices,
                    )
                  else if (_isProcessing)
                    ProcessingWidget(
                      pulseAnimation: _pulseAnimation,
                      detectionMode: widget.detectionMode,
                    )
                  else if (_image != null)
                    ImageResultWidget(
                      image: _image!,
                      detectedDisease: _detectedDisease,
                      confidence: _confidence,
                      onTakePhoto: () => _getImage(ImageSource.camera),
                      onSelectFromGallery: () => _getImage(ImageSource.gallery),
                    )
                  else
                    WelcomeWidget(
                      fadeAnimation: _fadeAnimation,
                      onTakePhoto: () => _getImage(ImageSource.camera),
                      onSelectFromGallery: () => _getImage(ImageSource.gallery),
                      detectionMode: widget.detectionMode,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _classifier.dispose();
    super.dispose();
  }
}