import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ayni/detection/services/plant_disease_classifier.dart';
import 'package:ayni/detection/services/detection_history_service.dart';
import 'package:ayni/detection/presentation/pages/detection_history_page.dart';
import 'package:ayni/detection/presentation/pages/detection_detail_page.dart';
import 'package:ayni/detection/data/models/detection_history_item.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

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
  String? _recommendation;
  
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  
  // Services
  final PlantDiseaseClassifier _classifier = PlantDiseaseClassifier();
  final DetectionHistoryService _historyService = DetectionHistoryService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeClassifier();
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

  Future<void> _initializeClassifier() async {
    setState(() {
      _isInitializing = true;
      _initError = null;
    });
    
    try {
      print('Attempting to initialize plant disease classifier...');
      final success = await _classifier.initialize();
      
      if (!success) {
        setState(() {
          _initError = 'Failed to initialize plant disease detector';
          _isInitializing = false;
        });
        
        if (mounted) {
          _showErrorSnackBar(
            'Failed to initialize plant disease detector. The model may be incompatible.',
            action: SnackBarAction(
              label: 'Details',
              onPressed: () => _showModelCompatibilityDialog(),
            ),
          );
        }
      } else {
        setState(() {
          _isInitializing = false;
        });
        _fadeController.forward();
        print('Successfully initialized plant disease classifier');
      }
    } catch (e) {
      print('Error initializing classifier: $e');
      
      setState(() {
        _initError = 'Error initializing: $e';
        _isInitializing = false;
      });
      
      if (mounted) {
        _showErrorSnackBar(
          'Error initializing: $e',
          action: SnackBarAction(
            label: 'Help',
            onPressed: () => _showModelCompatibilityDialog(),
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
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
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
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF00C851),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _showModelCompatibilityDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.warning_amber_rounded, 
                  color: Colors.orange[700], size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Model Compatibility Issue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: const Text(
                  'The plant detection model could not be initialized because it\'s incompatible with the current TFLite version.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'This usually happens when the model contains operations that aren\'t supported by tflite_flutter 0.11.0',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solutions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSolutionItem('Replace the model with a compatible version'),
                    _buildSolutionItem('Use the model downloader tool to get a compatible model'),
                    _buildSolutionItem('Check the MODEL_COMPATIBILITY.md file for more details'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C851),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _initializeClassifier();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
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
      print('Error picking image: $e');
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
      if (_initError != null) {
        bool success = await _classifier.initialize();
        if (!success) {
          setState(() {
            _isProcessing = false;
          });
          _showErrorSnackBar('Failed to initialize model. Please try again.');
          return;
        } else {
          setState(() {
            _initError = null;
          });
        }
      }

      final result = await _classifier.classifyImage(_image!);
      
      if (result == null) {
        setState(() {
          _isProcessing = false;
        });
        _showErrorSnackBar('Failed to analyze image. Please try with a different image.');
        return;
      }
      
      setState(() {
        _isProcessing = false;
        _detectedDisease = result.disease;
        _confidence = result.confidence;
        _recommendation = result.recommendation;
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
        print('Error saving to history: $e');
      }

      if (savedItem != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetectionDetailPage(detection: savedItem!),
          ),
        );
        return;
      }
      
      _showResultDialog(result.disease, result.confidence, result.recommendation);
      
    } catch (e) {
      print('Error during inference: $e');
      setState(() {
        _isProcessing = false;
      });
      _showErrorSnackBar('Error analyzing image: $e');
    }
  }

  void _showResultDialog(String disease, double confidence, String recommendation) {
    final isHealthy = disease == 'nodisease';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isHealthy 
                ? [Colors.green[50]!, Colors.green[100]!]
                : [Colors.orange[50]!, Colors.orange[100]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isHealthy ? Colors.green[200] : Colors.orange[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isHealthy ? Icons.eco : Icons.bug_report,
                  color: isHealthy ? Colors.green[700] : Colors.orange[700],
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Diagnosis Result',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isHealthy ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHealthy ? Colors.green[200]! : Colors.orange[200]!,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _formatDiseaseName(disease),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isHealthy ? Colors.green[800] : Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isHealthy ? Colors.green[100] : Colors.orange[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isHealthy ? Colors.green[800] : Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Recommendation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recommendation,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C851),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('More Info'),
          ),
        ],
      ),
    );
  }

  String _formatDiseaseName(String diseaseName) {
    switch (diseaseName) {
      case 'nodisease':
        return 'Healthy Plant';
      case 'miner':
        return 'Leaf Miner';
      case 'phoma':
        return 'Phoma Leaf Spot';
      case 'redspider':
        return 'Red Spider Mite';
      case 'rust': 
        return 'Leaf Rust';
      default:
        return diseaseName.split('_').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Plant Disease Detection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00C851),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C851), Color(0xFF00A142)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.history, size: 24),
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
            colors: [Colors.grey[50]!, Colors.white],
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
                    _buildInitializingWidget()
                  else if (_initError != null)
                    _buildErrorWidget()
                  else if (_isProcessing)
                    _buildProcessingWidget()
                  else if (_image != null)
                    _buildImageResultWidget()
                  else
                    _buildWelcomeWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitializingWidget() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C851).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
                const CircularProgressIndicator(
                  color: Color(0xFF00C851),
                  strokeWidth: 3,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Initializing AI Model',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we prepare the plant disease detector...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Initialization Failed',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              _initError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[700],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C851),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            onPressed: _initializeClassifier,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingWidget() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C851).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF00C851),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.psychology,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing Image',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI is examining your plant for diseases...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(
            color: Color(0xFF00C851),
            backgroundColor: Color(0xFFE8F5E8),
          ),
        ],
      ),
    );
  }

  Widget _buildImageResultWidget() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                _image!,
                height: 320,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          if (_detectedDisease != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _detectedDisease == 'nodisease' 
                    ? [Colors.green[50]!, Colors.green[100]!]
                    : [Colors.orange[50]!, Colors.orange[100]!],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _detectedDisease == 'nodisease' 
                    ? Colors.green[200]! 
                    : Colors.orange[200]!,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _detectedDisease == 'nodisease' ? Icons.eco : Icons.bug_report,
                    size: 40,
                    color: _detectedDisease == 'nodisease' 
                      ? Colors.green[700] 
                      : Colors.orange[700],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatDiseaseName(_detectedDisease!),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _detectedDisease == 'nodisease' 
                        ? Colors.green[800] 
                        : Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _detectedDisease == 'nodisease' 
                        ? Colors.green[200] 
                        : Colors.orange[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Confidence: ${(_confidence! * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _detectedDisease == 'nodisease' 
                          ? Colors.green[800] 
                          : Colors.orange[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C851),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => _getImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('New Photo', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => _getImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeWidget() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[50]!, Colors.green[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_florist,
                    size: 60,
                    color: Colors.green[600],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Plant Health Assistant',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Take a photo or upload an image to detect plant diseases with AI-powered analysis.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Feature cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.speed, size: 32, color: Colors.blue[600]),
                      const SizedBox(height: 8),
                      const Text(
                        'Fast Detection',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Results in seconds',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.psychology, size: 32, color: Colors.purple[600]),
                      const SizedBox(height: 8),
                      const Text(
                        'AI Powered',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Advanced analysis',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // Action buttons
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C851), Color(0xFF00A142)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C851).withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => _getImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt, size: 28, color: Colors.white),
              label: const Text(
                'Take Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => _getImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library, size: 28, color: Colors.grey[700]),
              label: Text(
                'Upload from Gallery',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
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

// Helper extension for reshaping lists, common in TFLite input/output.
extension ReshapeList<T> on List<T> {
  List<dynamic> reshape(List<int> shape) {
    if (shape.isEmpty) return this;

    List<T> flatList = List<T>.from(this);

    List<dynamic> reshape(List<T> list, List<int> currentShape) {
      if (currentShape.length == 1) {
        return List<T>.from(list.take(currentShape[0]));
      }
      List<dynamic> result = [];
      int nextDimSize = currentShape.length > 1 && currentShape[0] != 0 ? list.length ~/ currentShape[0] : list.length;
      if (currentShape[0] == 0) {
          return [];
      }

      for (int i = 0; i < currentShape[0]; i++) {
        if (list.length < (i + 1) * nextDimSize && currentShape.length > 1) {
            print("Warning: Not enough elements for full reshape, check dimensions and list size.");
            break;
        }
        result.add(reshape(list.sublist(i * nextDimSize, (i + 1) * nextDimSize), currentShape.sublist(1)));
      }
      return result;
    }
    return reshape(flatList, shape);
  }
}