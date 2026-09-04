import 'package:flutter/material.dart';
import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_nav_bar.dart';
import 'widgets/dashboard_body.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DashboardAppBar(),
      drawer: const DashboardNavBar(),
      body: const DashboardBody(),
    );
  }
}