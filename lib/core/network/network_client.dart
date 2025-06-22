import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../services/storage_service.dart';

enum RequestMethod { get, post, put, delete }

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;

  ApiResponse({
    this.data,
    this.error,
    required this.success,
  });
}

class NetworkClient {
  final http.Client _client;
  final StorageService _storageService;

  NetworkClient({
    http.Client? client,
    required StorageService storageService,
  }) : _client = client ?? http.Client(),
       _storageService = storageService;

  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required RequestMethod method,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    T Function(dynamic)? fromJson,
    bool requiresAuth = true,
    bool isMultipart = false,
  }) async {
    final url = Uri.parse(ApiConstants.baseUrl + endpoint);
    final requestHeaders = {
      ...?headers,
    };

    if (!isMultipart) {
      requestHeaders['Content-Type'] = 'application/json';
    }

    // Add authorization header if authentication is required
    if (requiresAuth) {
      final token = _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
    }

    http.Response response;

    try {
      if (isMultipart && data != null && data['file'] is File) {
        final request = http.MultipartRequest(method.toString().split('.').last.toUpperCase(), url);
        request.headers.addAll(requestHeaders);
        request.files.add(await http.MultipartFile.fromPath('file', data['file'].path));
        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        switch (method) {
          case RequestMethod.get:
            response = await _client.get(url, headers: requestHeaders);
            break;
          case RequestMethod.post:
            response = await _client.post(
              url,
              headers: requestHeaders,
              body: data != null ? jsonEncode(data) : null,
            );
            break;
          case RequestMethod.put:
            response = await _client.put(
              url,
              headers: requestHeaders,
              body: data != null ? jsonEncode(data) : null,
            );
            break;
          case RequestMethod.delete:
            response = await _client.delete(
              url,
              headers: requestHeaders,
              body: data != null ? jsonEncode(data) : null,
            );
            break;
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (fromJson != null && response.body.isNotEmpty) {
          try {
            final jsonData = jsonDecode(response.body);
            if (jsonData is Map<String, dynamic> || jsonData is List) {
              return ApiResponse<T>(
                data: fromJson(jsonData),
                success: true,
              );
            } else {
              return ApiResponse<T>(
                error: 'Invalid response format',
                success: false,
              );
            }
          } catch (e) {
            return ApiResponse<T>(
              error: 'Failed to parse response: $e',
              success: false,
            );
          }
        }
        return ApiResponse<T>(success: true);
      } else {
        String errorMessage = 'Request failed with status: ${response.statusCode}';
        try {
          if (response.body.isNotEmpty) {
            final errorJson = jsonDecode(response.body);
            if (errorJson != null && errorJson['message'] != null) {
              errorMessage = errorJson['message'];
            }
          }
        } catch (e) {
          // If there's an error parsing the JSON, use the default error message
        }
        
        return ApiResponse<T>(
          error: errorMessage,
          success: false,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        error: 'Network error: $e',
        success: false,
      );
    }
  }
}
