import 'package:flutter/material.dart';

import '../organization/organization_page.dart';
import '../organization/settings/settings_page.dart';

import '../sidebar/inventory/inventory_page.dart';
import '../sidebar/items_parts/items_parts_page.dart';
import '../sidebar/reports/reports_page.dart';

import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_body.dart';
import 'widgets/dashboard_nav_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ============================================================
  // SIDEBAR STATE
  // ============================================================

  bool _isSidebarCollapsed = false;

  // ============================================================
  // CURRENT SELECTED MENU
  // ============================================================

  String selectedMenu = 'dashboard';

  // ============================================================
  // TOGGLE SIDEBAR
  // ============================================================

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  // ============================================================
  // SELECT MENU
  // ============================================================

  void _selectMenu(String menu) {
    setState(() {
      selectedMenu = menu;
    });
  }

  // ============================================================
  // PROFILE CLICK
  // ============================================================

  void _openSuperAdminSettings() {
    setState(() {
      selectedMenu = 'all_settings';
    });
  }

  // ============================================================
  // BACK TO DASHBOARD
  // ============================================================

  void _goToDashboard() {
    setState(() {
      selectedMenu = 'dashboard';
    });
  }

  // ============================================================
  // BUILD SELECTED PAGE
  // ============================================================

  Widget _buildSelectedPage() {
    final menu = selectedMenu.toLowerCase().trim();

    switch (menu) {
      // ========================================================
      // DASHBOARD
      // ========================================================

      case 'dashboard':
        return const DashboardBody();

      // ========================================================
      // ORGANIZATION
      // ========================================================

      case 'organization':
        return OrganizationPage(
          onBack: _goToDashboard,
        );

      // ========================================================
      // ITEMS
      // ========================================================

      case 'items':
        return ItemsPartsPage(
          key: const ValueKey('items-page'),
          initialTab: 0,
          onSectionChanged: _selectMenu,
        );

      // ========================================================
      // PARTS
      // ========================================================

      case 'parts':
        return ItemsPartsPage(
          key: const ValueKey('parts-page'),
          initialTab: 1,
          onSectionChanged: _selectMenu,
        );

      // ========================================================
      // INVENTORY - CURRENT STOCK
      // ========================================================

      case 'inventory':
      case 'current stock':
      case 'current-stock':
        return InventoryPage(
          key: const ValueKey('current-stock-page'),
          initialTab: 0,
          onSectionChanged: _selectMenu,
        );

      // ========================================================
      // INVENTORY ADJUSTMENTS
      // ========================================================

      case 'inventory adjustments':
      case 'inventory-adjustments':
        return InventoryPage(
          key: const ValueKey('inventory-adjustments-page'),
          initialTab: 1,
          onSectionChanged: _selectMenu,
        );

      // ========================================================
      // RETURNABLE ASSETS
      // ========================================================

      case 'returnable assets':
      case 'returnable-assets':
        return InventoryPage(
          key: const ValueKey('returnable-assets-page'),
          initialTab: 2,
          onSectionChanged: _selectMenu,
        );

      // ========================================================
      // REPORTS
      // ========================================================

      case 'reports':
        return const ReportsPage();

      // ========================================================
      // SETTINGS
      // ========================================================

      case 'settings':
      case 'all_settings':
        return SettingsPage(
          onClose: _goToDashboard,
        );

      // ========================================================
      // SALES
      // ========================================================

      case 'sales':
      case 'customers':
        return _comingSoonPage(
          icon: Icons.people_outline,
          title: 'Customers',
        );

      case 'estimates':
        return _comingSoonPage(
          icon: Icons.description_outlined,
          title: 'Estimates',
        );

      case 'sales order':
      case 'sales-order':
        return _comingSoonPage(
          icon: Icons.shopping_cart_outlined,
          title: 'Sales Order',
        );

      case 'invoices':
        return _comingSoonPage(
          icon: Icons.receipt_long_outlined,
          title: 'Invoices',
        );

      case 'delivery challans':
      case 'delivery-challans':
        return _comingSoonPage(
          icon: Icons.local_shipping_outlined,
          title: 'Delivery Challans',
        );

      case 'payment received':
      case 'payment-received':
        return _comingSoonPage(
          icon: Icons.payments_outlined,
          title: 'Payment Received',
        );

      case 'credit notes':
      case 'credit-notes':
        return _comingSoonPage(
          icon: Icons.note_alt_outlined,
          title: 'Credit Notes',
        );

      // ========================================================
      // PURCHASE
      // ========================================================

      case 'purchase':
      case 'vendors':
        return _comingSoonPage(
          icon: Icons.storefront_outlined,
          title: 'Vendors',
        );

      case 'purchase orders':
      case 'purchase-orders':
        return _comingSoonPage(
          icon: Icons.shopping_bag_outlined,
          title: 'Purchase Orders',
        );

      case 'bills':
        return _comingSoonPage(
          icon: Icons.receipt_outlined,
          title: 'Bills',
        );

      case 'payment made':
      case 'payment-made':
        return _comingSoonPage(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Payment Made',
        );

      case 'vendor credit notes':
      case 'vendor-credit-notes':
        return _comingSoonPage(
          icon: Icons.note_outlined,
          title: 'Vendor Credit Notes',
        );

      // ========================================================
      // ACCOUNTANT
      // ========================================================

      case 'accountant':
      case 'expenses':
      case 'expense':
        return _comingSoonPage(
          icon: Icons.account_balance_outlined,
          title: 'Expenses',
        );

      case 'reimbursements':
        return _comingSoonPage(
          icon: Icons.currency_exchange_outlined,
          title: 'Reimbursements',
        );

      case 'travel allowance':
      case 'travel-allowance':
        return _comingSoonPage(
          icon: Icons.flight_takeoff_outlined,
          title: 'Travel Allowance',
        );

      case 'other claims':
      case 'other-claims':
        return _comingSoonPage(
          icon: Icons.request_page_outlined,
          title: 'Other Claims',
        );

      case 'investments':
        return _comingSoonPage(
          icon: Icons.trending_up_outlined,
          title: 'Investments',
        );

      case 'loans':
        return _comingSoonPage(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Loans',
        );

      // ========================================================
      // FLUXA HUB
      // ========================================================

      case 'fluxa hub':
      case 'fluxa-hub':
        return _comingSoonPage(
          icon: Icons.hub_outlined,
          title: 'Fluxa Hub',
        );

      // ========================================================
      // MY ACCOUNT
      // ========================================================

      case 'my account':
      case 'my-account':
        return _comingSoonPage(
          icon: Icons.person_outline,
          title: 'My Account',
        );

      // ========================================================
      // HELP
      // ========================================================

      case 'help':
        return _comingSoonPage(
          icon: Icons.help_outline_rounded,
          title: 'Help',
        );

      // ========================================================
      // DEFAULT
      // ========================================================

      default:
        return const DashboardBody();
    }
  }

  // ============================================================
  // COMING SOON PAGE
  // ============================================================

  Widget _comingSoonPage({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF4F7FA),
      child: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE3E8ED),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: const Color(0xFF245AA6),
                ),
              ),

              const SizedBox(height: 22),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF123653),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'This module is currently under development.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7A8791),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Coming Soon',
                style: TextStyle(
                  color: Color(0xFF245AA6),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DashboardAppBar(
        onMenuPressed: _toggleSidebar,
        onProfilePressed: _openSuperAdminSettings,
      ),
      body: Row(
        children: [
          // ======================================================
          // PERMANENT SIDEBAR
          // ======================================================

          DashboardNavBar(
            isCollapsed: _isSidebarCollapsed,
            selectedMenu: selectedMenu,
            onMenuSelected: _selectMenu,
          ),

          // ======================================================
          // PAGE CONTENT
          // ======================================================

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: KeyedSubtree(
                key: ValueKey(selectedMenu),
                child: _buildSelectedPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}