import 'package:ayni/plant/data/repositories/crop_repository.dart';
import 'package:ayni/plant/domain/entities/crop.dart';

class GetAllCrops {
  final CropRepository _repository;

  GetAllCrops(this._repository);

  Future<List<Crop>> call(int profileId) async {
    return await _repository.fetchCrops(profileId);
  }
}