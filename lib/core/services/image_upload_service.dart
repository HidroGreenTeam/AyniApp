import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ImageUploadService {
  static const String _uploadEndpoint = 'api/v1/upload/image';

  /// Sube una imagen al servidor y retorna la URL de la imagen
  Future<String> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse(ApiConstants.baseUrl + _uploadEndpoint);
      
      final request = http.MultipartRequest('POST', url);
      request.headers['accept'] = 'application/json';
      
      // Agregar el archivo de imagen
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);
        final imageUrl = jsonData['imageUrl'] ?? jsonData['url'];
        
        if (imageUrl != null) {
          return imageUrl.toString();
        } else {
          throw Exception('No se recibió URL de imagen en la respuesta');
        }
      } else {
        throw Exception('Error al subir imagen: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Sube una imagen usando el microservicio de detección
  Future<String> uploadImageToDetectionService(File imageFile) async {
    try {
      final url = Uri.parse('${ApiConstants.detectionServiceBaseUrl}api/v1/upload');
      
      final request = http.MultipartRequest('POST', url);
      request.headers['accept'] = 'application/json';
      
      // Agregar el archivo de imagen
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);
        final imageUrl = jsonData['imageUrl'] ?? jsonData['url'];
        
        if (imageUrl != null) {
          return imageUrl.toString();
        } else {
          throw Exception('No se recibió URL de imagen en la respuesta');
        }
      } else {
        throw Exception('Error al subir imagen: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }
} 