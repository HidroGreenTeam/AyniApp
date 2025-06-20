import 'package:flutter/material.dart';
import 'storage_service.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'es';
  
  final StorageService _storageService;
  Locale _currentLocale = const Locale('es');
  
  LocalizationService(this._storageService);
  
  Locale get currentLocale => _currentLocale;
  
  // Supported languages
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
  ];
  
  // Language names for UI
  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
  };
  
  // Language flags for UI
  static const Map<String, String> languageFlags = {
    'en': '🇺🇸',
    'es': '🇪🇸',
  };
  
  Future<void> initialize() async {
    final savedLanguage = _storageService.getString(_languageKey);
    if (savedLanguage != null) {
      _currentLocale = Locale(savedLanguage);
    } else {
      _currentLocale = const Locale(_defaultLanguage);
    }
    notifyListeners();
  }
  
  Future<void> setLanguage(String languageCode) async {
    if (supportedLocales.any((locale) => locale.languageCode == languageCode)) {
      _currentLocale = Locale(languageCode);
      await _storageService.setString(_languageKey, languageCode);
      notifyListeners();
    }
  }
  
  String getCurrentLanguageCode() {
    return _currentLocale.languageCode;
  }
  
  String getCurrentLanguageName() {
    return languageNames[_currentLocale.languageCode] ?? 'Unknown';
  }
  
  String getCurrentLanguageFlag() {
    return languageFlags[_currentLocale.languageCode] ?? '🏳️';
  }
  
  bool isEnglish() {
    return _currentLocale.languageCode == 'en';
  }
  
  bool isSpanish() {
    return _currentLocale.languageCode == 'es';
  }
} 