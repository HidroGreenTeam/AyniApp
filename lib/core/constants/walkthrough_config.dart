import 'package:flutter/material.dart';

/// Configuración del Walkthrough de Ayni
/// 
/// Esta clase centraliza todas las configuraciones visuales y de contenido
/// del walkthrough para mantener consistencia con el diseño de Figma.
class WalkthroughConfig {
  // === COLORES ===
  static const Color primaryGreen = Color(0xFF00C851);
  static const Color secondaryGreen = Color(0xFF007E33);
  static const Color logoGreen = Color(0xFF2E7D32);
  static const Color textColor = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color indicatorActiveColor = Color(0xFF00C851);
  static const Color indicatorInactiveColor = Color(0xFFE0E0E0);
  
  // === TIMING DE ANIMACIONES ===
  static const Duration pageAnimationDuration = Duration(milliseconds: 300);
  static const Duration iconAnimationDuration = Duration(milliseconds: 800);
  static const Duration textAnimationDuration = Duration(milliseconds: 600);
  
  // === DIMENSIONES ===
  static const double iconSize = 120.0;
  static const double titleFontSize = 28.0;
  static const double subtitleFontSize = 16.0;
  static const double buttonHeight = 56.0;
  static const double horizontalPadding = 32.0;
  
  // === TIPOGRAFÍA ===
  static const FontWeight titleFontWeight = FontWeight.w700;
  static const FontWeight subtitleFontWeight = FontWeight.w400;
  static const FontWeight buttonFontWeight = FontWeight.w600;
  
  // === GRADIENTE DE FONDO ===
  static const Gradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFE8F5E8),
    ],
  );
  
  // === SOMBRAS ===
  static final List<BoxShadow> cardShadows = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];
  
  static final List<BoxShadow> buttonShadows = [
    BoxShadow(
      color: primaryGreen.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Datos del contenido del walkthrough
class WalkthroughData {
  static List<WalkthroughItem> get items => [
    WalkthroughItem(
      icon: Icons.eco,
      title: "Tu Compañero de Cuidado de Plantas",
      subtitle: "Ayni te ayuda a cuidar de tus plantas. Establece recordatorios, documenta su crecimiento y diagnostica enfermedades con una rápida exploración de cámara.",
      animationDelay: Duration.zero,
    ),
    WalkthroughItem(
      icon: Icons.camera_alt,
      title: "Diagnóstico Inteligente",
      subtitle: "Toma fotos de tus plantas para diagnosticar enfermedades rápidamente. Identifica problemas como plagas, deficiencias de nutrientes y más.",
      animationDelay: const Duration(milliseconds: 200),
    ),
    WalkthroughItem(
      icon: Icons.people_alt,
      title: "Consulta con Expertos",
      subtitle: "Conecta con expertos en plantas cuando necesites ayuda especializada. Obtén consejos personalizados para el cuidado de tus plantas.",
      animationDelay: const Duration(milliseconds: 400),
    ),
    WalkthroughItem(
      icon: Icons.trending_up,
      title: "Haz Crecer tu Jardín",
      subtitle: "Monitorea el crecimiento de tus plantas, recibe recordatorios de cuidado y construye tu conocimiento sobre jardinería.",
      animationDelay: const Duration(milliseconds: 600),
    ),
  ];
}

/// Modelo de datos para cada página del walkthrough
class WalkthroughItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Duration animationDelay;

  const WalkthroughItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.animationDelay,
  });
}
