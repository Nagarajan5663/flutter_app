import 'package:flutter/material.dart';

import 'widgets/dashboard_nav_bar.dart';

// Dashboard content
import 'widgets/dashboard_body.dart';

// Items & Parts
import '../sidebar/items_parts/items_parts_page.dart';

// Inventory
import '../sidebar/inventory/inventory_page.dart';

// Settings
import '../settings/settings_page.dart';

// My Account
import '../sidebar/my_account/my_account_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ================================================================
  // CURRENT SIDEBAR SELECTION
  // ================================================================

  String selectedMenu = 'Dashboard';

  // ================================================================
  // CHANGE MENU
  // ================================================================

  void _selectMenu(String menu) {
    setState(() {
      selectedMenu = menu;
    });
  }

  // ================================================================
  // BUILD DASHBOARD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ==========================================================
          // PERMANENT SIDEBAR
          // ==========================================================

          DashboardNavBar(
            selectedMenu: selectedMenu,
            onMenuSelected: _selectMenu,
          ),

          // ==========================================================
          // RIGHT SIDE CONTENT
          // ==========================================================

          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // CONTENT ROUTING
  // ================================================================

  Widget _buildContent() {
    switch (selectedMenu) {
      // ============================================================
      // DASHBOARD
      // ============================================================

      case 'Dashboard':
        return const DashboardBody();

      // ============================================================
      // ITEMS
      // ============================================================

      case 'Items':
        return ItemsPartsPage(
          key: const ValueKey('items-page'),
          initialTab: 0,
          onSectionChanged: _selectMenu,
        );

      // ============================================================
      // PARTS
      // ============================================================

      case 'Parts':
        return ItemsPartsPage(
          key: const ValueKey('parts-page'),
          initialTab: 1,
          onSectionChanged: _selectMenu,
        );

      // ============================================================
      // CURRENT STOCK
      // ============================================================

      case 'Current Stock':
        return InventoryPage(
          key: const ValueKey('current-stock-page'),
          initialTab: 0,
          onSectionChanged: _selectMenu,
        );

      // ============================================================
      // INVENTORY ADJUSTMENTS
      // ============================================================

      case 'Inventory Adjustments':
        return InventoryPage(
          key: const ValueKey(
            'inventory-adjustments-page',
          ),
          initialTab: 1,
          onSectionChanged: _selectMenu,
        );

      // ============================================================
      // RETURNABLE ASSETS
      // ============================================================

      case 'Returnable Assets':
        return InventoryPage(
          key: const ValueKey(
            'returnable-assets-page',
          ),
          initialTab: 2,
          onSectionChanged: _selectMenu,
        );

      // ============================================================
      // SALES
      // ============================================================

      case 'Customers':
        return _comingSoon(
          'Customers',
          Icons.people,
        );

      case 'Estimates':
        return _comingSoon(
          'Estimates',
          Icons.request_quote,
        );

      case 'Sales Order':
        return _comingSoon(
          'Sales Order',
          Icons.shopping_cart,
        );

      case 'Invoices':
        return _comingSoon(
          'Invoices',
          Icons.receipt_long,
        );

      case 'Delivery Challans':
        return _comingSoon(
          'Delivery Challans',
          Icons.local_shipping,
        );

      case 'Payment Received':
        return _comingSoon(
          'Payment Received',
          Icons.payments,
        );

      case 'Credit Notes':
        return _comingSoon(
          'Credit Notes',
          Icons.note_alt,
        );

      // ============================================================
      // PURCHASE
      // ============================================================

      case 'Vendors':
        return _comingSoon(
          'Vendors',
          Icons.store,
        );

      case 'Purchase Orders':
        return _comingSoon(
          'Purchase Orders',
          Icons.shopping_bag,
        );

      case 'Bills':
        return _comingSoon(
          'Bills',
          Icons.receipt,
        );

      case 'Payment Made':
        return _comingSoon(
          'Payment Made',
          Icons.account_balance_wallet,
        );

      case 'Vendor Credit Notes':
        return _comingSoon(
          'Vendor Credit Notes',
          Icons.description,
        );

      // ============================================================
      // ACCOUNTANT
      // ============================================================

      case 'Expense':
        return _comingSoon(
          'Expense',
          Icons.money_off,
        );

      case 'Reimbursements':
        return _comingSoon(
          'Reimbursements',
          Icons.currency_rupee,
        );

      case 'Travel Allowance':
        return _comingSoon(
          'Travel Allowance',
          Icons.flight,
        );

      case 'Other Claims':
        return _comingSoon(
          'Other Claims',
          Icons.assignment,
        );

      case 'Investments':
        return _comingSoon(
          'Investments',
          Icons.trending_up,
        );

      case 'Loans':
        return _comingSoon(
          'Loans',
          Icons.account_balance,
        );

      // ============================================================
      // REPORTS
      // ============================================================

      case 'Reports':
        return _comingSoon(
          'Reports',
          Icons.bar_chart,
        );

      // ============================================================
      // FLUXA HUB
      // ============================================================

      case 'Fluxa Hub':
        return _comingSoon(
          'Fluxa Hub',
          Icons.hub,
        );

      // ============================================================
      // SETTINGS
      // ============================================================

      case 'Settings':
        return const SettingsPage();

      // ============================================================
      // MY ACCOUNT
      // ============================================================

      case 'My Account':
        return const MyAccountPage();

      // ============================================================
      // HELP
      // ============================================================

      case 'Help':
        return _comingSoon(
          'Help',
          Icons.help_outline,
        );

      // ============================================================
      // DEFAULT
      // ============================================================

      default:
        return _comingSoon(
          selectedMenu,
          Icons.construction,
        );
    }
  }

  // ================================================================
  // COMING SOON
  // ================================================================

  Widget _comingSoon(
    String title,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF4F6F9),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD9DEE5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 55,
                color: const Color(0xFF17395C),
              ),

              const SizedBox(height: 20),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17395C),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'This module is coming soon.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF777777),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}