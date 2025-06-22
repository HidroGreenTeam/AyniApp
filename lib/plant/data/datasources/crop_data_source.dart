import 'package:ayni/core/network/network_client.dart';
import 'package:ayni/plant/data/models/crop_model.dart';

class CropDataSource {

  final NetworkClient _networkClient;

  CropDataSource(this._networkClient);
  Future<ApiResponse<List<CropModel>>> fetchCrops(int farmerId) async {
    return await _networkClient.request<List<CropModel>>(
      endpoint: 'api/v1/crops/farmer/$farmerId/crops',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json['data'] is List) {
          return (json['data'] as List)
              .map((e) => CropModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
      requiresAuth: true,
    );
  }
}