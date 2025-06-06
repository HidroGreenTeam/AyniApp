import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);
  
  // Token management
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }
  
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }
    // User data management
  Future<void> saveUserData(String userData) async {
    await _prefs.setString(_userDataKey, userData);
  }
  
  String? getUserData() {
    return _prefs.getString(_userDataKey);
  }
  
  // General key-value storage
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }
  
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
  
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }
  
  String? getString(String key) {
    return _prefs.getString(key);
  }
    // Clear all stored data for logout
  Future<void> clearAll() async {
    await _prefs.clear();
  }
    // Clear only authentication data (preserves walkthrough status)
  Future<void> clearAuthData() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userDataKey);
  }
  
  // Remove specific key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
