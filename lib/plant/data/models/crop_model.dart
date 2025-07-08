class CropModel {
  final int id;
  final int profileId;
  final String cropName;
  final String plantingDate;
  final String location;
  final String healthStatus;
  final String notes;
  final String createdAt;
  final String updatedAt;

  CropModel({
    required this.id,
    required this.profileId,
    required this.cropName,
    required this.plantingDate,
    required this.location,
    required this.healthStatus,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'],
      profileId: json['profileId'],
      cropName: json['cropName'],
      plantingDate: json['plantingDate'],
      location: json['location'] ?? '',
      healthStatus: json['healthStatus'] ?? 'HEALTHY',
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'cropName': cropName,
      'plantingDate': plantingDate,
      'location': location,
      'healthStatus': healthStatus,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  CropModel copyWith({
    int? id,
    int? profileId,
    String? cropName,
    String? plantingDate,
    String? location,
    String? healthStatus,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return CropModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      cropName: cropName ?? this.cropName,
      plantingDate: plantingDate ?? this.plantingDate,
      location: location ?? this.location,
      healthStatus: healthStatus ?? this.healthStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
