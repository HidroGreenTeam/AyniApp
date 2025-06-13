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

class _CameraPageState extends State<CameraPage> {
  bool _isProcessing = false;
  bool _isInitializing = true; // Track initialization state
  String? _initError; // Store initialization error if any
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? _detectedDisease;
  double? _confidence;
  String? _recommendation;
  
  // Services
  final PlantDiseaseClassifier _classifier = PlantDiseaseClassifier();
  final DetectionHistoryService _historyService = DetectionHistoryService();

  @override
  void initState() {
    super.initState();
    _initializeClassifier();
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to initialize plant disease detector. The model may be incompatible.'),
              action: SnackBarAction(
                label: 'Details',
                onPressed: () => _showModelCompatibilityDialog(),
              ),
              duration: const Duration(seconds: 10),
            ),
          );
        }
      } else {
        setState(() {
          _isInitializing = false;
        });
        print('Successfully initialized plant disease classifier');
      }
    } catch (e) {
      print('Error initializing classifier: $e');
      
      setState(() {
        _initError = 'Error initializing: $e';
        _isInitializing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing: $e'),
            action: SnackBarAction(
              label: 'Help',
              onPressed: () => _showModelCompatibilityDialog(),
            ),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }
  
  void _showModelCompatibilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Model Compatibility Issue'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The plant detection model could not be initialized because it\'s incompatible with the current TFLite version.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'This usually happens when the model contains operations that aren\'t supported by tflite_flutter 0.11.0',
              ),
              SizedBox(height: 16),
              Text(
                'Solutions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Replace the model with a compatible version'),
              Text('2. Use the model downloader tool to get a compatible model'),
              Text('3. Check the MODEL_COMPATIBILITY.md file for more details'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C851),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _initializeClassifier(); // Try initializing again
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Get image from camera or gallery
  Future<void> _getImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isProcessing = true;
          _detectedDisease = null; // Reset previous detection
          _confidence = null;
        });
        await _runInference();
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }  // Process image and run inference using our classifier service
  Future<void> _runInference() async {
    if (_image == null) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      // Check if classifier is initialized
      if (_initError != null) {
        // Try to initialize again if there was a previous error
        bool success = await _classifier.initialize();
        if (!success) {
          setState(() {
            _isProcessing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to initialize model. Please try again.')),
          );
          return;
        } else {
          // Clear previous error if initialization succeeded
          setState(() {
            _initError = null;
          });
        }
      }

      // Run classification
      final result = await _classifier.classifyImage(_image!);
      
      if (result == null) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to analyze image. Please try with a different image.')),
        );
        return;
      }
      
      // Store results
      setState(() {
        _isProcessing = false;
        _detectedDisease = result.disease;
        _confidence = result.confidence;
        _recommendation = result.recommendation;
      });

      // Save to history
      DetectionHistoryItem? savedItem;
      try {
        savedItem = await _historyService.saveDetection(
          disease: result.disease,
          diseaseName: result.formattedDiseaseName,
          confidence: result.confidence,
          imageFile: _image!,
          recommendation: result.recommendation,
        );
        print('Detection saved to history successfully');
      } catch (e) {
        print('Error saving to history: $e');
        // Continue with detection even if history save fails
      }

      // Navegar a la página de detalle si se guardó correctamente
      if (savedItem != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetectionDetailPage(detection: savedItem!),
          ),
        );
        return;
      }
      // Display the result
      _showResultDialog(result.disease, result.confidence, result.recommendation);
      
    } catch (e) {
      print('Error during inference: $e');
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing image: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
  // Show detection results in a nicer dialog
  void _showResultDialog(String disease, double confidence, String recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              disease == 'nodisease' ? Icons.check_circle : Icons.warning_amber_rounded,
              color: disease == 'nodisease' ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 10),
            const Text('Diagnosis Result'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detected: ${_formatDiseaseName(disease)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              recommendation,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C851),
            ),
            onPressed: () {
              // TODO: Navigate to detailed information about the disease
              Navigator.of(context).pop();
            },
            child: const Text('More Info'),
          ),
        ],
      ),
    );
  }
  // Format disease name for display
  String _formatDiseaseName(String diseaseName) {
    switch (diseaseName) {
      case 'nodisease':
        return 'No Disease';
      case 'miner':
        return 'Leaf Miner';
      case 'phoma':
        return 'Phoma Leaf Spot';
      case 'redspider':
        return 'Red Spider Mite';
      case 'rust': 
        return 'Leaf Rust';
      default:
        // Generic formatting as fallback - replace underscores with spaces and capitalize each word
        return diseaseName.split('_').map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Detection'),
        backgroundColor: const Color(0xFF00C851),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Detection History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DetectionHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isInitializing)
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFF00C851),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Initializing classifier...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  )
                else if (_initError != null)
                  Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Initialization Failed',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          _initError!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _initializeClassifier,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  )
                else if (_isProcessing)
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFF00C851),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Processing image...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  )
                else if (_image != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _image!,
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Show result if available
                      if (_detectedDisease != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _detectedDisease == 'nodisease' 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _detectedDisease == 'nodisease' ? Colors.green : Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Result: ${_formatDiseaseName(_detectedDisease!)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _detectedDisease == 'nodisease' ? Colors.green[800] : Colors.orange[800],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Confidence: ${(_confidence! * 100).toStringAsFixed(2)}%',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C851),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _getImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('New Photo', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => _getImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Gallery', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Plant Disease Detection',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'Take a photo or upload an image from your gallery to detect plant diseases.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C851),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _getImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _getImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Upload from Gallery', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
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
