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
  
  // Clear all stored data for logout
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
