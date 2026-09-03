import 'package:flutter/material.dart';
import 'screens/home/home_page.dart';
import 'theme/app_colors.dart';

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