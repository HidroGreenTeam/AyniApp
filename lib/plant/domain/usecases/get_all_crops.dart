import 'package:ayni/plant/data/datasources/crop_data_source.dart';

class GetAllCrops {
  final CropDataSource _repository;

  GetAllCrops(this._repository);

  Future<List<Object>> call(int farmerId) async {
    final response = await _repository.fetchCrops(farmerId);
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Unknown error');
    }
  }
}