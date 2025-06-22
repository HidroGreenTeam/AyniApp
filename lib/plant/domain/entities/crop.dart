import '../../data/models/crop_model.dart';

class Crop {
  final int id;
  final String cropName;
  final String irrigationType;
  final int area;
  final String plantingDate;
  final int farmerId;
  final String? imageUrl;

  Crop({
    required this.id,
    required this.cropName,
    required this.irrigationType,
    required this.area,
    required this.plantingDate,
    required this.farmerId,
    this.imageUrl,
  });

  factory Crop.fromModel(CropModel model) => Crop(
        id: model.id,
        cropName: model.cropName,
        irrigationType: model.irrigationType,
        area: model.area,
        plantingDate: model.plantingDate,
        farmerId: model.farmerId,
        imageUrl: model.imageUrl,
      );

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        id: json['id'],
        cropName: json['cropName'],
        irrigationType: json['irrigationType'],
        area: json['area'],
        plantingDate: json['plantingDate'],
        farmerId: json['farmerId'],
        imageUrl: json['imageUrl'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropName': cropName,
        'irrigationType': irrigationType,
        'area': area,
        'plantingDate': plantingDate,
        'farmerId': farmerId,
        'imageUrl': imageUrl,
      };
}
