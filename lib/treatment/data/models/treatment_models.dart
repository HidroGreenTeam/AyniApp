// Modelos para el microservicio de tratamientos HidroBots

/// Modelo para crear un paso de tratamiento
class CreateTreatmentStepRequest {
  final String name;
  final String description;
  final DateTime scheduledDate;
  final bool hasReminder;
  final int? reminderMinutesBefore;

  CreateTreatmentStepRequest({
    required this.name,
    required this.description,
    required this.scheduledDate,
    this.hasReminder = false,
    this.reminderMinutesBefore,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'hasReminder': hasReminder,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  factory CreateTreatmentStepRequest.fromJson(Map<String, dynamic> json) {
    return CreateTreatmentStepRequest(
      name: json['name'],
      description: json['description'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      hasReminder: json['hasReminder'] ?? false,
      reminderMinutesBefore: json['reminderMinutesBefore'],
    );
  }
}

/// Respuesta de un paso de tratamiento
class TreatmentStepResponse {
  final int id;
  final String name;
  final String description;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String status;
  final bool hasReminder;
  final int? reminderMinutesBefore;
  final DateTime createdAt;
  final DateTime updatedAt;

  TreatmentStepResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.scheduledDate,
    this.completedDate,
    required this.status,
    required this.hasReminder,
    this.reminderMinutesBefore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TreatmentStepResponse.fromJson(Map<String, dynamic> json) {
    return TreatmentStepResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      completedDate: json['completedDate'] != null 
          ? DateTime.parse(json['completedDate'])
          : null,
      status: json['status'],
      hasReminder: json['hasReminder'] ?? false,
      reminderMinutesBefore: json['reminderMinutesBefore'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'status': status,
      'hasReminder': hasReminder,
      'reminderMinutesBefore': reminderMinutesBefore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Respuesta de un tratamiento
class TreatmentResponse {
  final int id;
  final int diagnosisId;
  final int cropId;
  final int profileId;
  final String title;
  final String description;
  final String diseaseType;
  final double confidence;
  final String status;
  final String severity;
  final String imageUrl;
  final DateTime diagnosisDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int activitiesCount;
  final int pendingActivitiesCount;
  final int completedActivitiesCount;
  final double progressPercentage;

  TreatmentResponse({
    required this.id,
    required this.diagnosisId,
    required this.cropId,
    required this.profileId,
    required this.title,
    required this.description,
    required this.diseaseType,
    required this.confidence,
    required this.status,
    required this.severity,
    required this.imageUrl,
    required this.diagnosisDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.activitiesCount,
    required this.pendingActivitiesCount,
    required this.completedActivitiesCount,
    required this.progressPercentage,
  });

  factory TreatmentResponse.fromJson(Map<String, dynamic> json) {
    return TreatmentResponse(
      id: json['id'],
      diagnosisId: json['diagnosisId'],
      cropId: json['cropId'],
      profileId: json['profileId'],
      title: json['title'],
      description: json['description'],
      diseaseType: json['diseaseType'],
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      status: json['status'],
      severity: json['severity'],
      imageUrl: json['imageUrl'] ?? '',
      diagnosisDate: DateTime.parse(json['diagnosisDate']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      activitiesCount: json['activitiesCount'] ?? 0,
      pendingActivitiesCount: (json['pendingActivitiesCount'] ?? 0).toInt(),
      completedActivitiesCount: (json['completedActivitiesCount'] ?? 0).toInt(),
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diagnosisId': diagnosisId,
      'cropId': cropId,
      'profileId': profileId,
      'title': title,
      'description': description,
      'diseaseType': diseaseType,
      'confidence': confidence,
      'status': status,
      'severity': severity,
      'imageUrl': imageUrl,
      'diagnosisDate': diagnosisDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'activitiesCount': activitiesCount,
      'pendingActivitiesCount': pendingActivitiesCount,
      'completedActivitiesCount': completedActivitiesCount,
      'progressPercentage': progressPercentage,
    };
  }
} 