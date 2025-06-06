import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central theme configuration for the Ayni app
/// Provides consistent colors, typography, and component styles throughout the application
/// 
/// Design System based on Style Guide:
/// - Primary Color: #04A033 (Brand Green)
/// - Secondary Color: #DDFFE7 (Light Green)
/// - Typography: Nunito (Google Fonts)
/// - State Colors: Info, Success, Warning, Error
/// - Black/White/Grey scales as defined in style guide
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      textTheme: _nunitoTextTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      bottomNavigationBarTheme: _bottomNavigationBarTheme,
      scaffoldBackgroundColor: AppColors.background,
      // Use Nunito as the primary font family
      fontFamily: GoogleFonts.nunito().fontFamily,
    );
  }
  /// Color scheme for light theme
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primaryGreen,
    onPrimary: AppColors.white,
    secondary: AppColors.secondaryGreen,
    onSecondary: AppColors.black,
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.white,
  );

  /// Nunito text theme with Style Guide specifications
  static TextTheme get _nunitoTextTheme {
    return GoogleFonts.nunitoTextTheme(
      const TextTheme(
        // Display styles - Large headings
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.12,
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.16,
          letterSpacing: 0,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.22,
          letterSpacing: 0,
        ),

        // Headline styles - Section headers
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.25,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.29,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.33,
          letterSpacing: 0,
        ),

        // Title styles - Component headers
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.27,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.50,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.43,
          letterSpacing: 0.10,
        ),

        // Body styles - Main content text
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.50,
          letterSpacing: 0.50,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.43,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.33,
          letterSpacing: 0.40,
        ),

        // Label styles - UI labels and captions
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.43,
          letterSpacing: 0.10,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          height: 1.33,
          letterSpacing: 0.50,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.45,
          letterSpacing: 0.50,
        ),
      ),
    );
  }

  /// AppBar theme
  static AppBarTheme get _appBarTheme {
    return AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
    );
  }

  /// Elevated button theme
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        minimumSize: const Size(double.infinity, 56),
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Outlined button theme
  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(
          color: AppColors.primaryGreen,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        minimumSize: const Size(double.infinity, 56),
        textStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Text button theme
  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        textStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Input decoration theme
  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(
          color: AppColors.primaryGreen,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
      hintStyle: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelStyle: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
  /// Card theme
  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      margin: const EdgeInsets.all(AppDimensions.paddingSmall),
    );
  }

  /// Bottom navigation bar theme
  static BottomNavigationBarThemeData get _bottomNavigationBarTheme {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textSecondary,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

/// App color constants
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Brand colors from Style Guide
  static const Color primaryGreen = Color(0xFF04A033);     // Primary brand color
  static const Color secondaryGreen = Color(0xFFDDFFE7);   // Secondary brand color
  static const Color logoGreen = Color(0xFF04A033);        // Logo color (same as primary)

  // Text colors
  static const Color textPrimary = Color(0xFF000000);      // Black
  static const Color textSecondary = Color(0xFF666666);    // Grey
  static const Color textDisabled = Color(0xFF9E9E9E);     // Light grey
  // Background colors
  static const Color backgroundColor = Color(0xFFFFFFFF);   // White background
  static const Color background = Color(0xFFFFFFFF);       // Main background
  static const Color white = Color(0xFFFFFFFF);            // Pure white
  static const Color inputBackground = Color(0xFFF5F5F5);   // Input field background
  static const Color lightGray = Color(0xFFF0F0F0);        // Light gray for backgrounds
  static const Color lightGreen = Color(0xFFE8F5E8);       // Light green for highlights

  // State colors from Style Guide
  static const Color info = Color(0xFFC2BFBF);             // Info state
  static const Color success = Color(0xFF27AE60);          // Success state
  static const Color warning = Color(0xFFE2B93B);          // Warning state
  static const Color error = Color(0xFFEB5757);            // Error state

  // Black/White/Grey scale
  static const Color black = Color(0xFF000000);            // Pure black
  static const Color grey900 = Color(0xFF1A1A1A);         // Dark grey
  static const Color grey800 = Color(0xFF333333);         // Medium dark grey
  static const Color grey700 = Color(0xFF4D4D4D);         // Medium grey
  static const Color grey600 = Color(0xFF666666);         // Medium light grey
  static const Color grey500 = Color(0xFF808080);         // Light grey
  static const Color grey400 = Color(0xFF999999);         // Lighter grey
  static const Color grey300 = Color(0xFFB3B3B3);         // Very light grey
  static const Color grey200 = Color(0xFFCCCCCC);         // Ultra light grey
  static const Color grey100 = Color(0xFFE6E6E6);         // Near white grey

  // Category colors
  static const Color flowering = Color(0xFFF8BBD9);
  static const Color foliage = Color(0xFFA5D6A7);
  static const Color trees = Color(0xFF66BB6A);
  static const Color shrubs = Color(0xFF4DB6AC);
  static const Color fruits = Color(0xFFFFAB91);
  static const Color vegetables = Color(0xFFC8E6C9);
  static const Color herbs = Color(0xFFE8F5E8);
  static const Color mushrooms = Color(0xFFD7CCC8);
  static const Color toxic = Color(0xFFFFCDD2);

  // Utility colors
  static const Color shadow = Color(0x1A000000);
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
}

/// App dimension constants
class AppDimensions {
  // Private constructor to prevent instantiation
  AppDimensions._();
  // Padding and margins
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Default padding for pages
  static const double defaultPadding = 20.0;
  static const double pagePadding = 20.0;  // Added missing pagePadding

  // Border radius
  static const double borderRadius = 8.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Button dimensions
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 40.0;

  // Image dimensions
  static const double categoryImageSize = 120.0;
  static const double avatarSize = 60.0;
  static const double logoSize = 140.0;
}

/// App text styles for specific use cases
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Custom text styles that don't fit in the theme
  static TextStyle get categoryTitle => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle get categorySubtitle => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static TextStyle get walkthroughTitle => GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle get walkthroughSubtitle => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get buttonText => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.25,
  );

  static TextStyle get inputLabel => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle get inputHint => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get errorText => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.error,
  );

  static TextStyle get successText => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.success,
  );
}
