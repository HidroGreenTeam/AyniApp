import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/network/network_client.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/di/service_locator.dart';
import 'plant_disease_classifier.dart';
import '../../../core/constants/api_constants.dart';

class DetectionResult {
  final String disease;
  final double confidence;
  final String formattedDiseaseName;
  final String recommendation;
  final bool isOnlineDetection;
  final String? warningMessage;

  DetectionResult({
    required this.disease,
    required this.confidence,
    required this.formattedDiseaseName,
    required this.recommendation,
    required this.isOnlineDetection,
    this.warningMessage,
  });
}

class HybridDetectionService {
  final PlantDiseaseClassifier _localClassifier = PlantDiseaseClassifier();
  final ConnectivityService _connectivityService = ConnectivityService();
  late final NetworkClient _networkClient;
  late final StorageService _storageService;

  HybridDetectionService() {
    _networkClient = serviceLocator<NetworkClient>();
    _storageService = serviceLocator<StorageService>();
  }

  /// Initialize the detection service
  Future<bool> initialize() async {
    try {
      // Initialize local classifier
      final localInitSuccess = await _localClassifier.initialize();
      if (!localInitSuccess) {
        debugPrint('Warning: Local classifier initialization failed');
      }
      return true;
    } catch (e) {
      debugPrint('Error initializing hybrid detection service: $e');
      return false;
    }
  }

  /// Detect plant disease using the best available method
  Future<DetectionResult?> detectDisease(File imageFile) async {
    try {
      // Check connectivity first
      final hasInternet = await _connectivityService.hasInternetConnection();
      
      if (hasInternet) {
        // Try online detection first
        final onlineResult = await _detectOnline(imageFile);
        if (onlineResult != null) {
          return onlineResult;
        }
        
        // If online fails, fallback to local
        debugPrint('Online detection failed, falling back to local detection');
      }
      
      // Use local detection (either no internet or online failed)
      return await _detectLocal(imageFile);
      
    } catch (e) {
      debugPrint('Error in hybrid detection: $e');
      return null;
    }
  }

  /// Detect using online model
  Future<DetectionResult?> _detectOnline(File imageFile) async {
    try {
      final response = await _networkClient.request<Map<String, dynamic>>(
        endpoint: ApiConstants.detectionAnalyze,
        method: RequestMethod.post,
        data: {'file': imageFile},
        isMultipart: true,
        requiresAuth: true,
        fromJson: (json) => json,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final disease = data['disease'] ?? 'unknown';
        final confidence = (data['confidence'] ?? 0.0).toDouble();
        
        return DetectionResult(
          disease: disease,
          confidence: confidence,
          formattedDiseaseName: _formatDiseaseName(disease),
          recommendation: _getRecommendationForDisease(disease),
          isOnlineDetection: true,
        );
      } else {
        debugPrint('Online detection failed: ${response.error}');
        return null;
      }
    } catch (e) {
      debugPrint('Error in online detection: $e');
      return null;
    }
  }

  /// Detect using local model
  Future<DetectionResult?> _detectLocal(File imageFile) async {
    try {
      final result = await _localClassifier.classifyImage(imageFile);
      
      if (result != null) {
        return DetectionResult(
          disease: result.disease,
          confidence: result.confidence,
          formattedDiseaseName: result.formattedDiseaseName,
          recommendation: result.recommendation,
          isOnlineDetection: false,
          warningMessage: 'Modelo local usado - menor precisión',
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('Error in local detection: $e');
      return null;
    }
  }

  /// Force local detection (for offline mode)
  Future<DetectionResult?> detectLocalOnly(File imageFile) async {
    try {
      final result = await _localClassifier.classifyImage(imageFile);
      
      if (result != null) {
        return DetectionResult(
          disease: result.disease,
          confidence: result.confidence,
          formattedDiseaseName: result.formattedDiseaseName,
          recommendation: result.recommendation,
          isOnlineDetection: false,
          warningMessage: 'Modo offline - modelo local',
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('Error in local-only detection: $e');
      return null;
    }
  }

  /// Force online detection (for testing or when user prefers online)
  Future<DetectionResult?> detectOnlineOnly(File imageFile) async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      throw Exception('No internet connection available for online detection');
    }
    
    return await _detectOnline(imageFile);
  }

  /// Check if online detection is available
  Future<bool> isOnlineDetectionAvailable() async {
    return await _connectivityService.hasInternetConnection();
  }

  /// Check if local detection is available
  Future<bool> isLocalDetectionAvailable() async {
    try {
      return await _localClassifier.initialize();
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  String _formatDiseaseName(String diseaseName) {
    if (diseaseName == 'nodisease') {
      return 'No Disease';
    } else if (diseaseName == 'unknown') {
      return 'Unknown';
    }
    
    return diseaseName.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

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
      case 'unknown':
        return 'Could not identify the plant condition. Try taking a clearer photo with better lighting.';
      default:
        return 'Consult with a plant specialist for proper treatment options.';
    }
  }

  void dispose() {
    _localClassifier.dispose();
  }
} 