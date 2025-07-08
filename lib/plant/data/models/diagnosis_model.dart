class DiagnosisModel {
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

  DiagnosisModel({
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

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
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
  }

  Map<String, dynamic> toJson() {
    return {
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

  DiagnosisModel copyWith({
    int? id,
    int? cropId,
    int? profileId,
    String? imageUrl,
    String? status,
    String? detectedDisease,
    bool? diseaseDetected,
    double? confidenceScore,
    String? recommendations,
    String? analyzedAt,
    String? notes,
  }) {
    return DiagnosisModel(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      profileId: profileId ?? this.profileId,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      detectedDisease: detectedDisease ?? this.detectedDisease,
      diseaseDetected: diseaseDetected ?? this.diseaseDetected,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      recommendations: recommendations ?? this.recommendations,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      notes: notes ?? this.notes,
    );
  }
} 