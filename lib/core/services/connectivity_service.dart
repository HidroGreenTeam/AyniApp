import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      // Check connectivity status
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult.isEmpty || connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      // Additional check: try to reach a reliable host
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        return false;
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  /// Check if device is connected to WiFi
  Future<bool> isConnectedToWifi() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.wifi);
    } catch (e) {
      debugPrint('Error checking WiFi connectivity: $e');
      return false;
    }
  }

  /// Check if device is connected to mobile data
  Future<bool> isConnectedToMobile() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile);
    } catch (e) {
      debugPrint('Error checking mobile connectivity: $e');
      return false;
    }
  }

  /// Get current connectivity status
  Future<List<ConnectivityResult>> getConnectivityStatus() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('Error getting connectivity status: $e');
      return [ConnectivityResult.none];
    }
  }

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }
} 