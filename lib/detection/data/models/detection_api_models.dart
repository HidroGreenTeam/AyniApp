// Modelos para las respuestas del microservicio de detección de plantas

/// Respuesta del endpoint /predict
class PredictionResponse {
  final String predictedClass;
  final double confidence;
  final bool diseaseDetected;
  final bool requiresTreatment;
  final Map<String, dynamic>? metadata;

  PredictionResponse({
    required this.predictedClass,
    required this.confidence,
    required this.diseaseDetected,
    required this.requiresTreatment,
    this.metadata,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      predictedClass: json['predicted_class'] ?? 'unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      diseaseDetected: json['disease_detected'] ?? false,
      requiresTreatment: json['requires_treatment'] ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predicted_class': predictedClass,
      'confidence': confidence,
      'disease_detected': diseaseDetected,
      'requires_treatment': requiresTreatment,
      'metadata': metadata,
    };
  }
}

/// Respuesta del endpoint /diagnose
class DiagnosisApiResponse {
  final int diagnosisId;
  final int cropId;
  final int profileId;
  final String imageUrl;
  final String imagePublicId;
  final String predictedClass;
  final double confidence;
  final bool diseaseDetected;
  final bool requiresTreatment;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiagnosisApiResponse({
    required this.diagnosisId,
    required this.cropId,
    required this.profileId,
    required this.imageUrl,
    required this.imagePublicId,
    required this.predictedClass,
    required this.confidence,
    required this.diseaseDetected,
    required this.requiresTreatment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiagnosisApiResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosisApiResponse(
      diagnosisId: json['diagnosis_id'],
      cropId: json['crop_id'],
      profileId: json['profile_id'],
      imageUrl: json['image_url'] ?? '',
      imagePublicId: json['image_public_id'] ?? '',
      predictedClass: json['predicted_class'] ?? 'unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      diseaseDetected: json['disease_detected'] ?? false,
      requiresTreatment: json['requires_treatment'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Getters de compatibilidad para el código existente
  int get id => diagnosisId;
  DateTime get diagnosisDate => createdAt;
  String get status => 'COMPLETED';
  String get severity => requiresTreatment ? 'HIGH' : 'LOW';
  String? get recommendations => null; // Se puede implementar basado en predicted_class
  String? get notes => null;

  Map<String, dynamic> toJson() {
    return {
      'diagnosis_id': diagnosisId,
      'crop_id': cropId,
      'profile_id': profileId,
      'image_url': imageUrl,
      'image_public_id': imagePublicId,
      'predicted_class': predictedClass,
      'confidence': confidence,
      'disease_detected': diseaseDetected,
      'requires_treatment': requiresTreatment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Respuesta para el historial de diagnósticos
class DiagnosisHistoryResponse {
  final List<DiagnosisApiResponse> diagnoses;
  final int total;
  final int page;
  final int pageSize;

  DiagnosisHistoryResponse({
    required this.diagnoses,
    required this.total,
    required this.page,
    required this.pageSize,
  });

  factory DiagnosisHistoryResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosisHistoryResponse(
      diagnoses: (json['diagnoses'] as List? ?? [])
          .map((e) => DiagnosisApiResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
    );
  }
}

/// Respuesta para estadísticas del servicio
class DetectionStatisticsResponse {
  final int totalDetections;
  final int diseasesDetected;
  final int healthyPlants;
  final Map<String, int> diseaseBreakdown;
  final double averageConfidence;

  DetectionStatisticsResponse({
    required this.totalDetections,
    required this.diseasesDetected,
    required this.healthyPlants,
    required this.diseaseBreakdown,
    required this.averageConfidence,
  });

  factory DetectionStatisticsResponse.fromJson(Map<String, dynamic> json) {
    return DetectionStatisticsResponse(
      totalDetections: json['total_detections'] ?? 0,
      diseasesDetected: json['diseases_detected'] ?? 0,
      healthyPlants: json['healthy_plants'] ?? 0,
      diseaseBreakdown: Map<String, int>.from(json['disease_breakdown'] ?? {}),
      averageConfidence: (json['average_confidence'] ?? 0.0).toDouble(),
    );
  }
}

/// Respuesta de health check
class HealthCheckResponse {
  final String status;
  final String version;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  HealthCheckResponse({
    required this.status,
    required this.version,
    required this.timestamp,
    this.details,
  });

  factory HealthCheckResponse.fromJson(Map<String, dynamic> json) {
    return HealthCheckResponse(
      status: json['status'] ?? 'unknown',
      version: json['version'] ?? '0.0.0',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      details: json['details'] as Map<String, dynamic>?,
    );
  }
} 