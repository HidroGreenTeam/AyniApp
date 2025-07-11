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
  final String? severity; // Puede ser null
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
    this.severity, // Nullable
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
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      diseaseType: json['diseaseType'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      status: _parseStatus(json['status']),
      severity: json['severity'], // Puede ser null
      imageUrl: json['imageUrl'] ?? '',
      diagnosisDate: _parseDateTime(json['diagnosisDate']),
      notes: json['notes'],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      activitiesCount: json['activitiesCount'] ?? 0,
      pendingActivitiesCount: (json['pendingActivitiesCount'] ?? 0).toInt(),
      completedActivitiesCount: (json['completedActivitiesCount'] ?? 0).toInt(),
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
    );
  }

  /// Convierte el formato de status del API a un string limpio
  static String _parseStatus(dynamic status) {
    if (status == null) return 'UNKNOWN';
    
    String statusStr = status.toString();
    
    // Si viene en formato "TreatmentStatus[status=IN_PROGRESS]", extraer el valor
    if (statusStr.contains('TreatmentStatus[status=')) {
      final start = statusStr.indexOf('=') + 1;
      final end = statusStr.indexOf(']');
      if (start > 0 && end > start) {
        return statusStr.substring(start, end);
      }
    }
    
    return statusStr;
  }

  /// Convierte fechas del API (que pueden venir como arrays o strings) a DateTime
  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    
    if (dateTime is String) {
      return DateTime.parse(dateTime);
    }
    
    if (dateTime is List && dateTime.length >= 6) {
      // Formato array: [2025, 7, 11, 6, 35, 39, 402611000]
      // [año, mes, día, hora, minuto, segundo, nanosegundos]
      final year = dateTime[0] as int;
      final month = dateTime[1] as int;
      final day = dateTime[2] as int;
      final hour = dateTime[3] as int;
      final minute = dateTime[4] as int;
      final second = dateTime[5] as int;
      final nanoseconds = dateTime.length > 6 ? dateTime[6] as int : 0;
      
      return DateTime(year, month, day, hour, minute, second, nanoseconds ~/ 1000000);
    }
    
    return DateTime.now();
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
      'severity': severity, // Puede ser null
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