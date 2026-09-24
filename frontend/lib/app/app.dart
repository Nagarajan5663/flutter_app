import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_page.dart';
import '../theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard App',

      theme: AppTheme.lightTheme,

      home: const DashboardPage(),
    );
  }
}