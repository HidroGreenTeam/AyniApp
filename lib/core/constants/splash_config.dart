import 'package:flutter/material.dart';

/// Configuración del Splash Screen de Ayni
/// 
/// Esta clase centraliza todas las configuraciones visuales y de timing
/// del splash screen para facilitar futuras personalizaciones.
class SplashConfig {  // === COLORES ===
  static const Color primaryGreen = Color(0xFF04A033);      // Updated to Style Guide
  static const Color secondaryGreen = Color(0xFFDDFFE7);    // Updated to Style Guide
  static const Color logoGreen = Color(0xFF04A033);         // Updated to Style Guide
  static const Color textColor = Color(0xFF000000);         // Updated to Style Guide
  
  // === TIMING DE ANIMACIONES ===
  static const Duration logoAnimationDuration = Duration(milliseconds: 1000);
  static const Duration textAnimationDuration = Duration(milliseconds: 800);
  static const Duration loadingAnimationDuration = Duration(milliseconds: 500);
  static const Duration rotationAnimationDuration = Duration(seconds: 8);
  
  // === DELAYS ===
  static const Duration initialDelay = Duration(milliseconds: 300);
  static const Duration textDelay = Duration(milliseconds: 500);
  static const Duration loadingDelay = Duration(milliseconds: 300);
  static const Duration navigationDelay = Duration(milliseconds: 1500);
  
  // === DIMENSIONES ===
  static const double logoSize = 140.0;
  static const double logoInnerSize = 120.0;
  static const double leafWidth = 35.0;
  static const double leafHeight = 50.0;
  static const double searchIconSize = 40.0;
  static const double loadingIndicatorSize = 32.0;
  
  // === TIPOGRAFÍA ===
  static const double titleFontSize = 64.0;
  static const FontWeight titleFontWeight = FontWeight.w900;
  static const double titleLetterSpacing = 3.0;
  
  // === EFECTOS ===
  static const double rotationIntensity = 0.1; // Intensidad de rotación del logo
  static const double pulseIntensity = 0.1; // Intensidad del efecto de pulsación
  static const double waveHeight = 20.0; // Altura de las ondas de fondo
  
  // === GRADIENTE DE FONDO ===
  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryGreen, secondaryGreen],
  );
  
  // === SOMBRAS ===
  static final List<Shadow> titleShadows = [
    const Shadow(
      offset: Offset(0, 4),
      blurRadius: 12,
      color: Color(0x4D000000),
    ),
    const Shadow(
      offset: Offset(0, 2),
      blurRadius: 6,
      color: Color(0x33000000),
    ),
  ];
  
  static final List<BoxShadow> logoShadows = [
    const BoxShadow(
      color: Color(0x33000000),
      blurRadius: 15,
      spreadRadius: 2,
      offset: Offset(0, 5),
    ),
  ];
}

/// Clase de utilidades para el splash screen
class SplashUtils {
  /// Calcula el efecto de pulsación basado en el valor de animación
  static double calculatePulseEffect(double animationValue) {
    return 1.0 + (SplashConfig.pulseIntensity * 
           (1.0 + (animationValue * 2 - 1).abs()));
  }
  
  /// Calcula la rotación sutil del logo
  static double calculateLogoRotation(double animationValue) {
    return animationValue * SplashConfig.rotationIntensity;
  }
  
  /// Crea el gradiente de fondo con colores personalizados
  static LinearGradient createBackgroundGradient({
    Color? topColor,
    Color? bottomColor,
  }) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        topColor ?? SplashConfig.primaryGreen,
        bottomColor ?? SplashConfig.secondaryGreen,
      ],
    );
  }
}
