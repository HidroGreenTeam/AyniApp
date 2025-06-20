import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app theme and appearance settings
/// 
/// This service handles:
/// - Theme mode switching (light/dark/system)
/// - Theme persistence using SharedPreferences
/// - Theme state management
class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  
  /// Current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Whether the app is currently in dark mode
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Use system brightness
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  /// Initialize the theme service and load saved preferences
  Future<void> initialize() async {
    await _loadThemeMode();
  }
  
  /// Set the theme mode and save to preferences
  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode != themeMode) {
      _themeMode = themeMode;
      await _saveThemeMode();
      notifyListeners();
    }
  }
  
  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
  
  /// Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeModeKey) ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex];
    } catch (e) {
      // If there's an error, default to system mode
      _themeMode = ThemeMode.system;
    }
  }
  
  /// Save theme mode to SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, _themeMode.index);
    } catch (e) {
      // Handle error silently
      debugPrint('Error saving theme mode: $e');
    }
  }
  
  /// Get theme mode display name
  String getThemeModeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Sistema';
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
    }
  }
  
  /// Get theme mode description
  String getThemeModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Sigue la configuración del sistema';
      case ThemeMode.light:
        return 'Tema claro para uso diurno';
      case ThemeMode.dark:
        return 'Tema oscuro para uso nocturno';
    }
  }
} 