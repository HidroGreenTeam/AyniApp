import 'dart:io';
import 'dart:typed_data'; // Import for Float32List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img; // Use prefix for image library
import 'package:flutter/services.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isProcessing = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  Interpreter? _interpreter;
  List<String>? _labels;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _loadLabels();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model/model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelsData.split('\n').map((label) => label.trim()).where((label) => label.isNotEmpty).toList();
      print('Labels loaded successfully: $_labels');
    } catch (e) {
      print('Failed to load labels: $e');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isProcessing = true;
      });
      _runInference();
    }
  }

  Future<void> _runInference() async {
    if (_image == null || _interpreter == null || _labels == null) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    // Preprocess the image
    var imageBytes = _image!.readAsBytesSync();
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      setState(() {
        _isProcessing = false;
      });
      print("Failed to decode image");
      return;
    }

    // Resize the image to the input size of the model (e.g., 300x300)
    img.Image resizedImage = img.copyResize(originalImage, width: 300, height: 300);

    // Convert the image to a Float32List
    var input = Float32List(1 * 300 * 300 * 3);
    var buffer = Float32List.view(input.buffer);
    int pixelIndex = 0;
    for (var y = 0; y < 300; y++) {
      for (var x = 0; x < 300; x++) {
        var pixel = resizedImage.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0;
        buffer[pixelIndex++] = pixel.b / 255.0;
      }
    }
    
    // The model output is Float32, so the output list should be Float32List.
    var outputBuffer = Float32List(_labels!.length);

    // Run inference
    // The input needs to be reshaped to match the model's expected input tensor shape.
    _interpreter!.run(input.reshape([1, 300, 300, 3]), outputBuffer.buffer.asFloat32List().reshape([1, _labels!.length]));

    // Process the output
    List<double> outputList = outputBuffer.toList();
    print('Output List: $outputList');

    // Get the index of the highest probability
    int maxIndex = 0;
    double maxValue = 0.0;
    for (int i = 0; i < outputList.length; i++) {
      if (outputList[i] > maxValue) {
        maxValue = outputList[i];
        maxIndex = i;
      }
    }
    
    String result = "Unknown";
    if (maxIndex < _labels!.length) {
        result = _labels![maxIndex];
    }


    setState(() {
      _isProcessing = false;
    });

    // Display the result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnosis Result'),
        content: Text('The plant is likely: $result (Confidence: ${(maxValue * 100).toStringAsFixed(2)}%)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take or Upload a Photo'),
        backgroundColor: const Color(0xFF00C851),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing)
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
                children: [
                  Image.file(
                    _image!,
                    height: 300,
                    width: 300, // Added explicit width
                    fit: BoxFit.contain, // Added BoxFit to handle aspect ratio
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C851),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _getImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Retake Photo', style: TextStyle(fontSize: 16)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _getImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('From Gallery', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                children: [
                  Icon(Icons.camera_alt, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Plant Disease Detection',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
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
    );
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }
}

// Helper extension for reshaping lists, common in TFLite input/output.
extension ReshapeList<T> on List<T> {
  List<dynamic> reshape(List<int> shape) {
    if (shape.isEmpty) return this;
    // int totalElements = 1;
    // for (int dim in shape) {
    //   totalElements *= dim;
    // }
    // if (totalElements != length) {
    //   throw ArgumentError('New shape $shape is not compatible with existing list of length $length');
    // }

    List<T> flatList = List<T>.from(this);

    List<dynamic> reshape(List<T> list, List<int> currentShape) {
      if (currentShape.length == 1) {
        // Ensure we don't try to take more elements than available
        return List<T>.from(list.take(currentShape[0]));
      }
      List<dynamic> result = [];
      // Calculate the size of the next dimension carefully
      int nextDimSize = currentShape.length > 1 && currentShape[0] != 0 ? list.length ~/ currentShape[0] : list.length;
      if (currentShape[0] == 0) { // Handle zero dimension to prevent division by zero
          return [];
      }

      for (int i = 0; i < currentShape[0]; i++) {
        if (list.length < (i + 1) * nextDimSize && currentShape.length > 1) {
            // This condition might indicate an issue with shape compatibility or list size
            // For robustness, one might throw an error or handle it based on specific needs
            // For now, let's break or adjust to prevent range errors if possible
            print("Warning: Not enough elements for full reshape, check dimensions and list size.");
            break; // Or handle differently
        }
        result.add(reshape(list.sublist(i * nextDimSize, (i + 1) * nextDimSize), currentShape.sublist(1)));
      }
      return result;
    }
    return reshape(flatList, shape);
  }
}
