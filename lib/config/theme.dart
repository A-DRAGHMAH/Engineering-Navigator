// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1a237e),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF1a237e),
      secondary: Colors.blue.shade700,
      surface: Colors.white,
      error: Colors.red.shade700,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      background: Colors.grey.shade50,
      onBackground: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1a237e),
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Color(0xFF1a237e),
      textColor: Colors.black87,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black87),
      titleMedium: TextStyle(color: Colors.black87),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF1a237e),
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF1a237e),
      secondary: Colors.blue.shade700,
      surface: const Color(0xFF1E1E1E),
      error: Colors.red.shade700,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      background: const Color(0xFF121212),
      onBackground: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1a237e),
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white,
      textColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    dividerColor: Colors.white24,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFF2A2A2A),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade700),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIconColor: Colors.white70,
      suffixIconColor: Colors.white70,
    ),
    searchBarTheme: SearchBarThemeData(
      backgroundColor: MaterialStateProperty.all(const Color(0xFF2A2A2A)),
      elevation: MaterialStateProperty.all(0),
      shadowColor: MaterialStateProperty.all(Colors.transparent),
      surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
      overlayColor: MaterialStateProperty.all(Colors.white10),
      side: MaterialStateProperty.all(
        const BorderSide(color: Colors.white24),
      ),
      textStyle: MaterialStateProperty.all(
        const TextStyle(color: Colors.white),
      ),
      hintStyle: MaterialStateProperty.all(
        const TextStyle(color: Colors.white70),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: const Color(0xFF2A2A2A),
      surfaceTintColor: Colors.transparent,
      textStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dataTableTheme: const DataTableThemeData(
      headingTextStyle: TextStyle(color: Colors.white),
      dataTextStyle: TextStyle(color: Colors.white70),
      headingRowColor: MaterialStatePropertyAll(Color(0xFF2A2A2A)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(color: Colors.white),
      menuStyle: MenuStyle(
        backgroundColor: MaterialStateProperty.all(const Color(0xFF2A2A2A)),
        surfaceTintColor: MaterialStateProperty.all(Colors.transparent),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
  );
}
