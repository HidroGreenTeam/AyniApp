class CropModel {
  final int id;
  final String cropName;
  final String irrigationType;
  final int area;
  final String plantingDate;
  final int farmerId;
  final String? imageUrl;

  CropModel({
    required this.id,
    required this.cropName,
    required this.irrigationType,
    required this.area,
    required this.plantingDate,
    required this.farmerId,
    this.imageUrl,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    return CropModel(
      id: json['id'],
      cropName: json['cropName'],
      irrigationType: json['irrigationType'],
      area: json['area'],
      plantingDate: json['plantingDate'],
      farmerId: json['farmerId'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropName': cropName,
      'irrigationType': irrigationType,
      'area': area,
      'plantingDate': plantingDate,
      'farmerId': farmerId,
      'imageUrl': imageUrl,
    };
  }

  CropModel copyWith({
    int? id,
    String? cropName,
    String? irrigationType,
    int? area,
    String? plantingDate,
    int? farmerId,
    String? imageUrl,
  }) {
    return CropModel(
      id: id ?? this.id,
      cropName: cropName ?? this.cropName,
      irrigationType: irrigationType ?? this.irrigationType,
      area: area ?? this.area,
      plantingDate: plantingDate ?? this.plantingDate,
      farmerId: farmerId ?? this.farmerId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
