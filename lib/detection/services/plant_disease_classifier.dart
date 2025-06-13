import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class PlantDiseaseResult {
  final String disease;
  final double confidence;
  final String formattedDiseaseName;
  final String recommendation;

  PlantDiseaseResult({
    required this.disease,
    required this.confidence,
    required this.formattedDiseaseName,
    required this.recommendation,
  });
}

class PlantDiseaseClassifier {
  static const int inputSize = 300; // Model input size
  static const int numChannels = 3; // RGB channels

  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Load the model
      _interpreter = await Interpreter.fromAsset('model/model.tflite');
      
      // Load labels
      final labelsData = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();
      
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Error initializing plant disease classifier: $e');
      return false;
    }
  }

  Future<PlantDiseaseResult?> classifyImage(File imageFile) async {
    if (!_isInitialized || _interpreter == null || _labels == null) {
      if (!await initialize()) {
        return null;
      }
    }

    try {
      // Preprocess the image
      var imageBytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        print("Failed to decode image");
        return null;
      }

      // Resize the image to the input size of the model
      img.Image resizedImage = img.copyResize(
        originalImage, 
        width: inputSize, 
        height: inputSize
      );

      // Convert the image to a Float32List and normalize values to [0,1]
      var input = Float32List(1 * inputSize * inputSize * numChannels);
      var buffer = Float32List.view(input.buffer);
      int pixelIndex = 0;
      
      for (var y = 0; y < inputSize; y++) {
        for (var x = 0; x < inputSize; x++) {
          var pixel = resizedImage.getPixel(x, y);
          buffer[pixelIndex++] = pixel.r / 255.0;
          buffer[pixelIndex++] = pixel.g / 255.0;
          buffer[pixelIndex++] = pixel.b / 255.0;
        }
      }
      
      // Prepare output buffer based on number of classes
      var outputBuffer = Float32List(_labels!.length);

      // Reshape input for the model
      List<dynamic> reshapedInput = _reshapeList(
        input, 
        [1, inputSize, inputSize, numChannels]
      );
      
      List<dynamic> reshapedOutput = _reshapeList(
        outputBuffer.buffer.asFloat32List(), 
        [1, _labels!.length]
      );

      // Run inference
      _interpreter!.run(reshapedInput, reshapedOutput);

      // Process the output
      List<double> outputList = outputBuffer.toList();

      // Get the index of the highest probability
      int maxIndex = 0;
      double maxValue = 0.0;
      for (int i = 0; i < outputList.length; i++) {
        if (outputList[i] > maxValue) {
          maxValue = outputList[i];
          maxIndex = i;
        }
      }
      
      // Get result
      String disease = "unknown";
      if (maxIndex < _labels!.length) {
        disease = _labels![maxIndex];
      }

      return PlantDiseaseResult(
        disease: disease,
        confidence: maxValue,
        formattedDiseaseName: _formatDiseaseName(disease),
        recommendation: _getRecommendationForDisease(disease),
      );
    } catch (e) {
      print('Error during classification: $e');
      return null;
    }
  }

  // Format disease name for display
  String _formatDiseaseName(String diseaseName) {
    if (diseaseName == 'nodisease') {
      return 'No Disease';
    }
    
    // Replace underscores with spaces and capitalize each word
    return diseaseName.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  // Get recommendation based on detected disease
  String _getRecommendationForDisease(String disease) {
    switch (disease.toLowerCase()) {
      case 'nodisease':
        return 'Your plant appears healthy! Continue with your current care routine.';
      case 'miner':
        return 'Leaf miner detected. Consider removing affected leaves and applying appropriate insecticide.';
      case 'phoma':
        return 'Phoma leaf spot detected. Avoid overhead watering and apply appropriate fungicide.';
      case 'redspider':
        return 'Red spider mites detected. Increase humidity and consider applying insecticidal soap.';
      case 'rust':
        return 'Leaf rust detected. Remove affected parts and apply a copper-based fungicide.';
      default:
        return 'Consult with a plant specialist for proper treatment options.';
    }
  }

  // Helper function to reshape lists for TFLite input/output
  List<dynamic> _reshapeList<T>(List<T> list, List<int> shape) {
    if (shape.isEmpty) return list;

    List<T> flatList = List<T>.from(list);

    List<dynamic> reshape(List<T> list, List<int> currentShape) {
      if (currentShape.length == 1) {
        return List<T>.from(list.take(currentShape[0]));
      }
      List<dynamic> result = [];
      int nextDimSize = currentShape.length > 1 && currentShape[0] != 0 
          ? list.length ~/ currentShape[0] 
          : list.length;
          
      if (currentShape[0] == 0) {
          return [];
      }

      for (int i = 0; i < currentShape[0]; i++) {
        if (list.length < (i + 1) * nextDimSize && currentShape.length > 1) {
            print("Warning: Not enough elements for full reshape.");
            break;
        }
        result.add(reshape(
          list.sublist(i * nextDimSize, (i + 1) * nextDimSize), 
          currentShape.sublist(1)
        ));
      }
      return result;
    }
    
    return reshape(flatList, shape);
  }

  void dispose() {
    _interpreter?.close();
  }
}
