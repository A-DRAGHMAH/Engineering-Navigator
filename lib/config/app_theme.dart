// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData ocean = _createTheme(
    primary: const Color(0xFF0A4D68),
    secondary: const Color(0xFF088395),
    surface: const Color(0xFF05BFDB),
    gradientColors: const [
      Color(0xFF0A4D68),
      Color(0xFF088395),
      Color(0xFF05BFDB),
    ],
  );

  static ThemeData sunset = _createTheme(
    primary: const Color(0xFFE65100),
    secondary: const Color(0xFFF57C00), 
    surface: const Color(0xFF2C1810),
    gradientColors: const [
      Color(0xFFE65100),
      Color(0xFFF57C00),
      Color(0xFFFF8F00),
    ],
  );

  static ThemeData emerald = _createTheme(
    primary: const Color(0xFF2E7D32),
    secondary: const Color(0xFF388E3C),
    surface: const Color(0xFF0F2417),
    gradientColors: const [
      Color(0xFF2E7D32),
      Color(0xFF388E3C),
      Color(0xFF43A047),
    ],
  );

  static ThemeData royal = _createTheme(
    primary: const Color(0xFF4527A0),
    secondary: const Color(0xFF512DA8),
    surface: const Color(0xFF1A1429),
    gradientColors: const [
      Color(0xFF4527A0),
      Color(0xFF512DA8),
      Color(0xFF5E35B1),
    ],
  );

  static ThemeData midnight = _createTheme(
    primary: const Color(0xFF1A1A1A),
    secondary: const Color(0xFF2C2C2C),
    surface: const Color(0xFF121212),
    gradientColors: const [
      Color(0xFF1A1A1A),
      Color(0xFF2C2C2C),
      Color(0xFF3D3D3D),
    ],
  );

  // Similar pattern for other themes...

  static ThemeData _createTheme({
    required Color primary,
    required Color secondary,
    required Color surface,
    required List<Color> gradientColors,
  }) {
    final theme = ThemeData(
      primaryColor: primary,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: primary,
        secondary: secondary,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: surface.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary),
        ),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      ),
      dividerTheme: DividerThemeData(
        color: primary.withOpacity(0.2),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primary.withOpacity(0.2),
        labelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(color: Colors.white),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        elevation: 16,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
    theme.setGradientColors(gradientColors);
    return theme;
  }
}

extension ThemeDataExtensions on ThemeData {
  static final Map<ThemeData, List<Color>> _gradientColors = {};

  void setGradientColors(List<Color> colors) {
    _gradientColors[this] = colors;
  }

  List<Color> get gradientColors {
    return _gradientColors[this] ?? [primaryColor];
  }
} 