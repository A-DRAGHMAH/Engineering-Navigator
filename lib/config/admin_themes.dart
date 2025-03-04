import 'package:flutter/material.dart';

class AdminTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1A237E),
    scaffoldBackgroundColor: Colors.grey[100],
    cardColor: Colors.white,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: Colors.black87,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF8B0000),
    scaffoldBackgroundColor: const Color(0xFF1A1A2F),
    cardColor: Colors.white10,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
  );
} 