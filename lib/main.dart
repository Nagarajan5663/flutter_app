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
      debugShowCheckedModeBanner: false,
      title: 'Codexia',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: CodexiaColors.navy,

        colorScheme: ColorScheme.fromSeed(
          seedColor: CodexiaColors.gold,
          brightness: Brightness.dark,
        ),

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

      home: const HomePage(),
    );
  }
}