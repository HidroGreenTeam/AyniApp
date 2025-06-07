import 'package:ayni/plant/domain/entities/crop.dart';
import 'package:ayni/core/network/network_client.dart';

class CropRepository {
  final NetworkClient networkClient;
  CropRepository({required this.networkClient});

  Future<List<Crop>> fetchCrops(int farmerId) async {
    final response = await networkClient.request<List<Crop>>(
      endpoint: 'api/v1/crops/farmer/$farmerId/crops',
      method: RequestMethod.get,
      fromJson: (json) {
        // Permitir respuesta tipo List o Map con 'data'
        if (json is List) {
          return (json as List)
              .map((e) => Crop.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (json['data'] is List) {
          return (json['data'] as List)
              .map((e) => Crop.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
      requiresAuth: true,
    );
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Unknown error');
    }
  }

  Future<Crop> createCrop(Map<String, dynamic> cropData) async {
    final response = await networkClient.request<Crop>(
      endpoint: 'api/v1/crops',
      method: RequestMethod.post,
      data: cropData,
      fromJson: (json) => Crop.fromJson(json),
      requiresAuth: true,
    );
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Unknown error');
    }
  }

  Future<Crop> updateCrop(int cropId, Map<String, dynamic> cropData) async {
    final response = await networkClient.request<Crop>(
      endpoint: 'api/v1/crops/$cropId',
      method: RequestMethod.put,
      data: cropData,
      fromJson: (json) => Crop.fromJson(json),
      requiresAuth: true,
    );
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Unknown error');
    }
  }

  Future<void> deleteCrop(int cropId) async {
    final response = await networkClient.request(
      endpoint: 'api/v1/crops/$cropId',
      method: RequestMethod.delete,
      requiresAuth: true,
    );
    if (!response.success) {
      throw Exception(response.error ?? 'Unknown error');
    }
  }
}
