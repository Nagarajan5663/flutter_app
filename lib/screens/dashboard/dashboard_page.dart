import 'package:flutter/material.dart';

import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_nav_bar.dart';
import 'widgets/dashboard_body.dart';

import '../sidebar/reports/reports_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isSidebarCollapsed = false;

  // Default page
  String _selectedPage = 'dashboard';

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  // Called from sidebar
  void _changePage(String page) {
    setState(() {
      _selectedPage = page;
    });
  }

  // Main content
  Widget _buildPage() {
    switch (_selectedPage) {
      case 'reports':
        return const ReportsPage();

      case 'dashboard':
      default:
        return const DashboardBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardAppBar(
        onMenuPressed: _toggleSidebar,
      ),

      body: Row(
        children: [
          // =========================================================
          // FIXED SIDEBAR
          // =========================================================
          DashboardNavBar(
            isCollapsed: _isSidebarCollapsed,
            onPageSelected: _changePage,
          ),

          // =========================================================
          // ONLY THIS AREA CHANGES
          // =========================================================
          Expanded(
            child: _buildPage(),
          ),
        ],
      ),
    );
  }
}