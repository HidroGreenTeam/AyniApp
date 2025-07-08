import '../../data/models/diagnosis_model.dart';

class Diagnosis {
  final int id;
  final int cropId;
  final int profileId;
  final String imageUrl;
  final String status;
  final String detectedDisease;
  final bool diseaseDetected;
  final double confidenceScore;
  final String recommendations;
  final String analyzedAt;
  final String notes;

  Diagnosis({
    required this.id,
    required this.cropId,
    required this.profileId,
    required this.imageUrl,
    required this.status,
    required this.detectedDisease,
    required this.diseaseDetected,
    required this.confidenceScore,
    required this.recommendations,
    required this.analyzedAt,
    required this.notes,
  });

  factory Diagnosis.fromModel(DiagnosisModel model) => Diagnosis(
        id: model.id,
        cropId: model.cropId,
        profileId: model.profileId,
        imageUrl: model.imageUrl,
        status: model.status,
        detectedDisease: model.detectedDisease,
        diseaseDetected: model.diseaseDetected,
        confidenceScore: model.confidenceScore,
        recommendations: model.recommendations,
        analyzedAt: model.analyzedAt,
        notes: model.notes,
      );

  factory Diagnosis.fromJson(Map<String, dynamic> json) => Diagnosis(
        id: json['id'],
        cropId: json['cropId'],
        profileId: json['profileId'],
        imageUrl: json['imageUrl'] ?? '',
        status: json['status'] ?? 'PENDING',
        detectedDisease: json['detectedDisease'] ?? '',
        diseaseDetected: json['diseaseDetected'] ?? false,
        confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
        recommendations: json['recommendations'] ?? '',
        analyzedAt: json['analyzedAt'] ?? '',
        notes: json['notes'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropId': cropId,
        'profileId': profileId,
        'imageUrl': imageUrl,
        'status': status,
        'detectedDisease': detectedDisease,
        'diseaseDetected': diseaseDetected,
        'confidenceScore': confidenceScore,
        'recommendations': recommendations,
        'analyzedAt': analyzedAt,
        'notes': notes,
      };
} 