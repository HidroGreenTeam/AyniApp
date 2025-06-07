import 'package:ayni/auth/domain/usecases/auth_usecases.dart';
import 'package:ayni/plant/domain/domain/entities/crop.dart';
import 'package:ayni/plant/domain/usecases/get_all_crops.dart';

class CropViewmodel {
  final GetAllCrops _getAllCrops;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  List<Crop> crops = [];

  CropViewmodel(this._getAllCrops, this._getCurrentUserUseCase);

  Future<void> fetchCrops() async {
    final user = await _getCurrentUserUseCase();
    final int? farmerId = user?.id != null ? int.tryParse(user!.id) : null;
    if (farmerId != null) {
      crops = (await _getAllCrops(farmerId)).cast<Crop>();
    } else {
      crops = [];
    }
  }
}