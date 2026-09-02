import 'package:flutter/material.dart';
import 'screens/home/home_page.dart';

void main() {
  runApp(const CodexiaApp());
}

class CodexiaApp extends StatelessWidget {
  const CodexiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner from the top-right corner.
      debugShowCheckedModeBanner: false,

      // Application name.
      title: 'Codexia',

      // Global theme for the application.
      theme: ThemeData(
        useMaterial3: true,

        // Main font.
        fontFamily: 'Arial',

        // Default background.
        scaffoldBackgroundColor: CodexiaColors.navy,

        // Application color scheme.
        colorScheme: ColorScheme.fromSeed(
          seedColor: CodexiaColors.gold,
          brightness: Brightness.dark,
        ),

        // Default button theme.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: CodexiaColors.gold,
            foregroundColor: CodexiaColors.navyDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // First page shown when the app starts.
      home: const HomePage(),
    );
  }
}


// ============================================================
// CODEXIA COLORS
// ============================================================

class CodexiaColors {
  // Main dark blue.
  static const Color navy = Color(0xFF0D3154);

  // Darker blue used for header/footer.
  static const Color navyDark = Color(0xFF092846);

  // Card background.
  static const Color card = Color(0xFF1B4165);

  // Card border.
  static const Color cardBorder = Color(0xFF315779);

  // Gold color used throughout the Codexia design.
  static const Color gold = Color(0xFFD99A3E);

  // Main white text.
  static const Color white = Color(0xFFF7F8FA);

  // Secondary/muted text.
  static const Color muted = Color(0xFFB8C7D8);
}