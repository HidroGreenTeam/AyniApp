import 'package:ayni/plant/data/repositories/crop_repository.dart';
import 'package:ayni/plant/domain/entities/diagnosis.dart';

class StartDiagnosisUseCase {
  final CropRepository _repository;

  StartDiagnosisUseCase(this._repository);

  Future<Diagnosis> call(Map<String, dynamic> diagnosisData) async {
    return await _repository.startDiagnosis(diagnosisData);
  }
} 