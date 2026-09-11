import 'package:flutter/material.dart';

import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_nav_bar.dart';
import 'widgets/dashboard_body.dart';

// Reports
import '../sidebar/reports/reports_page.dart';
import '../sidebar/items_parts/items_parts_page.dart';
import '../sidebar/inventory/inventory_page.dart';
import '../sidebar/sales/customer/customers_page.dart';
import '../sidebar/sales/estimates/estimates_page.dart';
import '../sidebar/sales/sales_orders/sales_orders_page.dart';
import '../sidebar/sales/invoices/invoices_page.dart';
import '../sidebar/sales/delivery_challans/delivery_challans_page.dart';
import '../sidebar/sales/payments_received/payments_received_page.dart';
import '../sidebar/sales/credit_notes/credit_notes_page.dart';
import '../sidebar/purchase/vendors/vendors_page.dart';
import '../sidebar/purchase/purchase_orders/purchase_orders_page.dart';
import '../sidebar/purchase/bills/bills_page.dart';
import '../sidebar/purchase/payments_made/payments_page.dart';
import '../sidebar/purchase/vendor_credit_notes/vendor_credit_notes_page.dart';
import '../sidebar/Accountant/expenses/expenses_page.dart';
import '../sidebar/Accountant/reimbursements/reimbursements_page.dart';
import '../sidebar/Accountant/travel_allowance/travel_allowance_page.dart';
import '../sidebar/Accountant/other_claims/other_claims_page.dart';
import '../sidebar/investment/investment_page.dart';
import '../sidebar/Accountant/loans/loans_page.dart';

// All Settings
import '../settings/settings_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ================================================================
  // SIDEBAR COLLAPSE
  // ================================================================

  bool _isSidebarCollapsed = false;

  // ================================================================
  // CURRENT PAGE
  // ================================================================

  String selectedMenu = 'dashboard';

  // ================================================================
  // SIDEBAR OPEN / CLOSE
  // ================================================================

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  // ================================================================
  // SIDEBAR MENU CLICK
  // ================================================================

  void _selectMenu(String menu) {
    setState(() {
      selectedMenu = menu;
    });
  }

  // ================================================================
  // SUPER ADMIN ICON CLICK
  //
  // SUPER ADMIN -> ALL SETTINGS
  // ================================================================

  void _openSuperAdminSettings() {
    setState(() {
      selectedMenu = 'all_settings';
    });
  }

  // ================================================================
  // BUILD RIGHT-SIDE BODY
  // ================================================================

  Widget _buildSelectedPage() {
    switch (selectedMenu.toLowerCase().trim()) {
      // ============================================================
      // DASHBOARD
      // ============================================================

      case 'dashboard':
        return const DashboardBody();

      // ============================================================
      // REPORTS
      // ============================================================

      case 'reports':
        return const ReportsPage();

      // ============================================================
      // SUPER ADMIN -> ALL SETTINGS
      // ============================================================

      case 'all_settings':
        return SettingsPage(
          onClose: () {
            setState(() {
              selectedMenu = 'dashboard';
            });
          },
        );

      // ============================================================
      // ITEMS
      // ============================================================

      case 'items':
        return const ItemsPartsPage(
          initialTab: 0,
        );

      case 'parts':
        return const ItemsPartsPage(
          initialTab: 1,
        );

      // ============================================================
      // INVENTORY
      // ============================================================

      case 'inventory':
        return const InventoryPage(
          initialTab: 0,
        );

      case 'current stock':
        return const InventoryPage(
          initialTab: 0,
        );

      case 'inventory adjustments':
        return const InventoryPage(
          initialTab: 1,
        );

      case 'returnable assets':
        return const InventoryPage(
          initialTab: 2,
        );

      // ============================================================
      // SALES
      // ============================================================

      case 'sales':
        return const CustomersPage();

      case 'customers':
        return const CustomersPage();

      case 'estimates':
        return const EstimatesPage();

      case 'sales order':
        return const SalesOrderPage();

      case 'invoices':
        return const InvoicesPage();

      case 'delivery challans':
        return const DeliveryChallansPage();

      case 'payment received':
        return const PaymentsReceivedPage();

      case 'credit notes':
        return const CreditNotesPage();

      // ============================================================
      // PURCHASE
      // ============================================================

      case 'purchase':
        return const VendorsPage();

      case 'vendors':
        return const VendorsPage();

      case 'purchase orders':
        return const PurchaseOrdersPage();

      case 'bills':
        return const BillsPage();

      case 'payment made':
        return const PaymentsPage();

      case 'vendor credit notes':
        return const VendorCreditNotesPage();

      // ============================================================
      // ACCOUNTANT
      // ============================================================

      case 'accountant':
        return const ExpensesPage();

      case 'expense':
        return const ExpensesPage();

      case 'reimbursements':
        return const ReimbursementsPage();

      case 'travel allowance':
        return const TravelAllowancePage();

      case 'other claims':
        return const OtherClaimsPage();

      case 'investments':
        return const InvestmentPage();

      case 'loans':
        return const LoansPage();

      // ============================================================
      // FLUXA HUB
      // ============================================================

      case 'fluxa hub':
        return _comingSoonPage(
          icon: Icons.hub_outlined,
          title: 'Fluxa Hub',
        );

      // ============================================================
      // MY ACCOUNT
      // ============================================================

      case 'my account':
        return _comingSoonPage(
          icon: Icons.account_circle_outlined,
          title: 'My Account',
        );

      // ============================================================
      // HELP
      // ============================================================

      case 'help':
        return _comingSoonPage(
          icon: Icons.help_outline_rounded,
          title: 'Help',
        );

      // ============================================================
      // DEFAULT
      // ============================================================

      default:
        return const DashboardBody();
    }
  }

  // ================================================================
  // TEMPORARY PAGE
  // ================================================================

  Widget _comingSoonPage({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF4F7FA),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: const Color(0xFF245AA6),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF123653),
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon',
              style: TextStyle(
                color: Color(0xFF7A8791),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // MAIN BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ============================================================
      // DEFAULT APP BAR
      // ALWAYS STAYS
      // ============================================================

      appBar: DashboardAppBar(
        onMenuPressed: _toggleSidebar,

        // ==========================================================
        // SUPER ADMIN ICON
        // CLICK -> ALL SETTINGS
        // ==========================================================

        onProfilePressed: _openSuperAdminSettings,
      ),

      // ============================================================
      // SIDEBAR + BODY
      // ============================================================

      body: Row(
        children: [
          // ========================================================
          // EXISTING SIDEBAR
          // ========================================================

          DashboardNavBar(
            isCollapsed: _isSidebarCollapsed,
            selectedMenu: selectedMenu,
            onMenuSelected: _selectMenu,
          ),

          // ========================================================
          // ONLY RIGHT SIDE CHANGES
          // ========================================================

          Expanded(
            child: _buildSelectedPage(),
          ),
        ],
      ),
    );
  }
}
