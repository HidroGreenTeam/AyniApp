import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

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

  NetworkClient({http.Client? client}) : _client = client ?? http.Client();

  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required RequestMethod method,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final url = Uri.parse(ApiConstants.baseUrl + endpoint);
    final requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    http.Response response;

    try {
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (fromJson != null && response.body.isNotEmpty) {
          final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
          return ApiResponse<T>(
            data: fromJson(jsonData),
            success: true,
          );
        }
        return ApiResponse<T>(success: true);      } else {
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
