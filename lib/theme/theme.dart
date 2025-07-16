import 'package:flutter/material.dart';

class AppTheme {
  /// Dark Theme (VS Code Dark)
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(
        0xFF1E1E1E,
      ), // VS Code dark background

      primaryColor: const Color(0xFF9B59B6), // Sunset purple
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF9B59B6), // AppBar, focus
        secondary: Color(0xFF007BFF), // Blue accent
        error: Color(0xFFFF4C4C), // Red for errors/deletes
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF9B59B6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF), // Blue
          foregroundColor: Colors.white,
          shadowColor: Colors.redAccent, // Red glow
          elevation: 12,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      textTheme: TextTheme(
        bodyLarge: const TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.grey[300]),
        titleLarge: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey[600]),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF9B59B6)),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) => const Color(0xFF9B59B6),
        ),
        checkColor: WidgetStateProperty.resolveWith<Color>(
          (states) => Colors.white,
        ),
      ),
    );
  }

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light background

      primaryColor: const Color(0xFF9B59B6), // Sunset purple
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF9B59B6), // AppBar, focus
        secondary: Color(0xFF007BFF), // Blue accent
        error: Color(0xFFFF4C4C), // Red for errors/deletes
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF9B59B6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF), // Blue
          foregroundColor: Colors.white,
          shadowColor: Colors.redAccent, // Red glow
          elevation: 12,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      textTheme: TextTheme(
        bodyLarge: const TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.grey[800]),
        titleLarge: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey[600]),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF9B59B6)),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>(
          (states) => const Color(0xFF9B59B6),
        ),
        checkColor: WidgetStateProperty.resolveWith<Color>(
          (states) => Colors.white,
        ),
      ),
    );
  }

  /// System Theme (Follows Device Settings)
  static ThemeData get systemTheme {
    return ThemeData(
      brightness: WidgetsBinding.instance.window.platformBrightness,
    );
  }
}
