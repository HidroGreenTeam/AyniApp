import 'dart:convert';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/network_client.dart' as network;
import '../../../core/services/storage_service.dart';
import '../../../core/utils/api_response.dart';
import '../models/profile_models.dart';

class ProfileDataSource {
  final network.NetworkClient _networkClient;
  final StorageService _storageService;

  ProfileDataSource(this._networkClient, this._storageService);

  /// Obtener farmer/profile por ID
  Future<ApiResponse<ProfileModel>>    getProfileById(String farmerId) async {
    final response = await _networkClient.request<ProfileModel>(
      endpoint: '${ApiConstants.farmers}/$farmerId',
      method: network.RequestMethod.get,
      fromJson: (json) => ProfileModel.fromJson(json),
    );
    if (response.success && response.data != null) {
      // print('[DEBUG] ProfileDataSource.getProfileById: {response.data}'); // Removed for production
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }

  /// Obtener todos los farmers/perfiles
  Future<ApiResponse<List<ProfileModel>>> getAllProfiles() async {
    final response = await _networkClient.request<List<ProfileModel>>(
      endpoint: ApiConstants.farmers,
      method: network.RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return (json).map<ProfileModel>((item) => ProfileModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        if (json['data'] != null && json['data'] is List) {
          return (json['data'] as List)
              .map((item) => ProfileModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <ProfileModel>[];
      },
    );
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }

  /// Crear un nuevo farmer/profile
  Future<ApiResponse<ProfileModel>> createProfile(CreateProfileRequest request) async {
    final response = await _networkClient.request<ProfileModel>(
      endpoint: ApiConstants.farmers,
      method: network.RequestMethod.post,
      data: request.toJson(),
      fromJson: (json) => ProfileModel.fromJson(json),
    );
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }

  /// Actualizar farmer/profile existente
  Future<ApiResponse<ProfileModel>> updateProfile(String farmerId, UpdateProfileRequest request) async {
    final response = await _networkClient.request<ProfileModel>(
      endpoint: '${ApiConstants.farmers}/$farmerId',
      method: network.RequestMethod.put,
      data: request.toJson(),
      fromJson: (json) => ProfileModel.fromJson(json),
    );
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }

  /// Eliminar farmer/profile
  Future<ApiResponse<void>> deleteProfile(String farmerId) async {
    final response = await _networkClient.request<void>(
      endpoint: '${ApiConstants.farmers}/$farmerId',
      method: network.RequestMethod.delete,
    );
    if (response.success) {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }

  /// Buscar farmers (perfiles) localmente por nombre o email
  Future<ApiResponse<List<ProfileModel>>> searchProfiles({
    String? search,
    String? location, // No usado, pero mantenido para compatibilidad
    List<String>? interests, // No usado, pero mantenido para compatibilidad
    int page = 1,
    int limit = 10,
  }) async {
    final response = await getAllProfiles();
    if (!response.success || response.data == null) {
      return ApiResponse.error(response.error ?? 'Error al buscar farmers');
    }
    var list = response.data!;
    if (search != null && search.isNotEmpty) {
      list = list.where((p) => (p.username.toLowerCase().contains(search.toLowerCase()) || p.email.toLowerCase().contains(search.toLowerCase()))).toList();
    }
    // Paginación simple
    final start = (page - 1) * limit;
    final end = (start + limit) > list.length ? list.length : (start + limit);
    final paged = (start < list.length) ? list.sublist(start, end) : <ProfileModel>[];
    return ApiResponse.success(paged);
  }

  /// Subir imagen de farmer
  Future<ApiResponse<ProfileModel>> uploadProfilePicture(String farmerId, String imagePath) async {
    final response = await _networkClient.request<ProfileModel>(
      endpoint: '${ApiConstants.farmers}/$farmerId/farmerImage',
      method: network.RequestMethod.put,
      data: {'file': imagePath},
      fromJson: (json) => ProfileModel.fromJson(json),
    );
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.error ?? 'Error al subir imagen');
    }
  }

  /// Obtener el perfil del usuario autenticado
  Future<ApiResponse<ProfileModel>> getCurrentProfile() async {
    // Obtener el id del usuario autenticado desde el storage
    final userData = _storageService.getUserData();
    // print('[DEBUG] userData from storage:'); // Removed for production
    // print(userData); // Removed for production
    if (userData == null) {
      // print('[DEBUG] userData is null'); // Removed for production
      return ApiResponse.error('No user data found');
    }
    try {
      final userJson = userData.toString();
      // print('[DEBUG] userJson:'); // Removed for production
      // print(userJson); // Removed for production
      final userMap = userJson.isNotEmpty ? Map<String, dynamic>.from(await Future.value(jsonDecode(userJson))) : null;
      // print('[DEBUG] userMap:'); // Removed for production
      // print(userMap); // Removed for production
      final userId = userMap != null && userMap['id'] != null ? userMap['id'].toString() : null;
      // print('[DEBUG] userId:'); // Removed for production
      // print(userId); // Removed for production
      if (userId == null) {
        // print('[DEBUG] userId is null'); // Removed for production
        return ApiResponse.error('No user id found');
      }
      return getProfileById(userId);
    } catch (e) {
      // print('[DEBUG] Error parsing user data: $e'); // Removed for production
      return ApiResponse.error('Error parsing user data: $e');
    }
  }
}
