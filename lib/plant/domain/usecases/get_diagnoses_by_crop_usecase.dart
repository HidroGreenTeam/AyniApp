import 'package:ayni/plant/data/repositories/crop_repository.dart';
import 'package:ayni/plant/domain/entities/diagnosis.dart';

class GetDiagnosesByCropUseCase {
  final CropRepository _repository;

  GetDiagnosesByCropUseCase(this._repository);

  Future<List<Diagnosis>> call(int cropId) async {
    return await _repository.getDiagnosesByCropId(cropId);
  }
} 