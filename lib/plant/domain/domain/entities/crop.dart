import 'package:equatable/equatable.dart';

class Crop extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? plantingDate;
  final String? harvestDate;
  final int farmerId;

  const Crop({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.plantingDate,
    this.harvestDate,
    required this.farmerId,
  });

  @override
  List<Object?> get props => [id, name, description, imageUrl, plantingDate, harvestDate, farmerId];
}