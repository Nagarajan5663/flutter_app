import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // Whole app background
    scaffoldBackgroundColor: const Color(0xFF0B1F3A),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: Colors.grey,
      thickness: 1,
      space: 1,
    ),
  );
}