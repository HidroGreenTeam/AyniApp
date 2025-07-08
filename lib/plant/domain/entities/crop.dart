import '../../data/models/crop_model.dart';

class Crop {
  final int id;
  final int profileId;
  final String cropName;
  final String plantingDate;
  final String location;
  final String healthStatus;
  final String notes;
  final String createdAt;
  final String updatedAt;

  Crop({
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

  factory Crop.fromModel(CropModel model) => Crop(
        id: model.id,
        profileId: model.profileId,
        cropName: model.cropName,
        plantingDate: model.plantingDate,
        location: model.location,
        healthStatus: model.healthStatus,
        notes: model.notes,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
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

  Map<String, dynamic> toJson() => {
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
