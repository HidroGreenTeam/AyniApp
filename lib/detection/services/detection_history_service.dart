import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:ayni/detection/data/models/detection_history_item.dart';

class DetectionHistoryService {
  static const String _prefKey = 'detection_history';
  final Uuid _uuid = const Uuid();

  // Save a detection to history
  Future<DetectionHistoryItem> saveDetection({
    required String disease,
    required String diseaseName,
    required double confidence,
    required File imageFile,
    required String recommendation,
  }) async {
    try {
      // Create a unique ID for this detection
      final id = _uuid.v4();
      
      // Copy the image to app documents directory for persistence
      final appDir = await getApplicationDocumentsDirectory();
      final historyDir = Directory('${appDir.path}/detection_history');
      
      if (!await historyDir.exists()) {
        await historyDir.create(recursive: true);
      }

      // Generate a unique filename for the image
      final fileName = 'detection_$id${path.extension(imageFile.path)}';
      final savedImagePath = '${historyDir.path}/$fileName';
      
      // Copy the image file
      await imageFile.copy(savedImagePath);
      
      // Create history item
      final historyItem = DetectionHistoryItem(
        id: id,
        disease: disease,
        diseaseName: diseaseName,
        confidence: confidence,
        imagePath: savedImagePath,
        timestamp: DateTime.now(),
        recommendation: recommendation,
      );
      
      // Save to storage
      await _addToHistory(historyItem);
      
      return historyItem;
    } catch (e) {
      print('Error saving detection to history: $e');
      rethrow;
    }
  }

  // Get all detection history items
  Future<List<DetectionHistoryItem>> getDetectionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_prefKey) ?? [];
      
      return historyJson.map((item) {
        return DetectionHistoryItem.fromMap(json.decode(item));
      }).toList();
    } catch (e) {
      print('Error retrieving detection history: $e');
      return [];
    }
  }

  // Add a detection to history
  Future<void> _addToHistory(DetectionHistoryItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_prefKey) ?? [];
      
      // Convert the item to JSON and add to the list
      historyJson.add(json.encode(item.toMap()));
      
      // Keep only the last 30 detections
      if (historyJson.length > 30) {
        historyJson.removeAt(0);
      }
      
      await prefs.setStringList(_prefKey, historyJson);
    } catch (e) {
      print('Error adding to detection history: $e');
      rethrow;
    }
  }

  // Delete a detection from history
  Future<void> deleteDetection(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_prefKey) ?? [];
      
      // Find the item to delete
      final List<String> updatedHistory = [];
      String? imagePath;
      
      for (final item in historyJson) {
        final decodedItem = json.decode(item);
        if (decodedItem['id'] != id) {
          updatedHistory.add(item);
        } else {
          imagePath = decodedItem['imagePath'];
        }
      }
      
      // Delete the associated image file
      if (imagePath != null) {
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
      
      // Save the updated history
      await prefs.setStringList(_prefKey, updatedHistory);
    } catch (e) {
      print('Error deleting detection from history: $e');
      rethrow;
    }
  }
}
