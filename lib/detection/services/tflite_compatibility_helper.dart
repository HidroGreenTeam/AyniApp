import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Helper class to handle TFLite model compatibility issues
class TFLiteCompatibilityHelper {
  /// Attempt to load model in different ways to check for compatibility issues
  static Future<Interpreter?> createCompatibleInterpreter() async {
    debugPrint('Attempting to create compatible interpreter...');
      // First try to check TFLite version
    try {
      final version = "checking for version";
      debugPrint('TFLite version: $version');
    } catch (e) {
      debugPrint('Could not get TFLite version: $e');
    }
    
    // Check if model file exists and its size
    try {
      final modelData = await rootBundle.load('assets/model/model.tflite');
      debugPrint('Model file loaded from assets, size: ${modelData.lengthInBytes} bytes');
    } catch (e) {
      debugPrint('Error checking model file: $e');
    }
    
    try {
      // First attempt: try direct loading (most reliable when it works)
      debugPrint('Method 1: Loading model directly from assets');
      final options = InterpreterOptions()..threads = 4;
      
      return await Interpreter.fromAsset(
        'assets/model/model.tflite',
        options: options,
      );
    } catch (e) {
      debugPrint('Method 1 failed: $e');
      debugPrint('Error details: ${e.toString()}');
      
      try {
        // Second attempt: try loading from extracted file
        debugPrint('Method 2: Loading model from extracted file');
        final modelData = await rootBundle.load('assets/model/model.tflite');
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/temp_model.tflite';
        
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(
          modelData.buffer.asUint8List(modelData.offsetInBytes, modelData.lengthInBytes)
        );
        
        debugPrint('File extracted to: $tempPath');
        if (await tempFile.exists()) {
          debugPrint('File exists and is ${await tempFile.length()} bytes');
        }
        
        return Interpreter.fromFile(tempFile);
      } catch (e) {
        debugPrint('Method 2 failed: $e');
        debugPrint('Error details: ${e.toString()}');
        
        try {
          // Third attempt: try using different options
          debugPrint('Method 3: Using different interpreter options');
          final options = InterpreterOptions()
            ..threads = 1
            ..useNnApiForAndroid = false;
          
          return await Interpreter.fromAsset(
            'assets/model/model.tflite',
            options: options,
          );
        } catch (e) {
          debugPrint('Method 3 failed: $e');
          debugPrint('Error details: ${e.toString()}');
          
          try {
            // Fourth attempt: try using null options
            debugPrint('Method 4: Using null options');
            return await Interpreter.fromAsset(
              'assets/model/model.tflite',
            );
          } catch (e) {
            debugPrint('Method 4 failed: $e');
            debugPrint('Error details: ${e.toString()}');
            
            debugPrint('All loading methods failed. Model may be incompatible with this tflite_flutter version.');
            debugPrint('Recommended solutions:');
            debugPrint('1. Check if model format is compatible with tflite_flutter 0.11.0');
            debugPrint('2. Check for unsupported operations in the model');
            debugPrint('3. Try converting the model to a compatible format');
            return null;
          }
        }
      }
    }
  }

  /// Utility method to check if labels file is accessible
  static Future<List<String>?> loadLabels() async {
    try {
      debugPrint('Loading labels file...');
      final labelsData = await rootBundle.loadString('assets/model/labels.txt');
      final labels = labelsData
          .split('\n')
          .map((label) => label.trim())
          .where((label) => label.isNotEmpty)
          .toList();
      
      debugPrint('Labels loaded successfully: $labels');
      return labels;
    } catch (e) {
      debugPrint('Failed to load labels: $e');
      return null;
    }
  }
}
