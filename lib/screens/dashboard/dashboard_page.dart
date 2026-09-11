import 'package:flutter/material.dart';

import '../accountant/expenses/expenses_page.dart';
import '../accountant/investments/investment_page.dart';
import '../accountant/loans/loans_page.dart';
import '../accountant/other_claims/other_claims_page.dart';
import '../accountant/reimbursements/reimbursements_page.dart';
import '../accountant/travel_allowance/travel_allowance_page.dart';

import '../organization/organization_page.dart';
import '../organization/settings/settings_page.dart';

import '../purchase/bills/bills_page.dart';
import '../purchase/payment_made/payments_page.dart';
import '../purchase/purchase_orders/purchase_orders_page.dart';
import '../purchase/vendor_credit_notes/vendor_credit_notes_page.dart';
import '../purchase/vendors/vendors_page.dart';

import '../sales/credit_notes/credit_notes_page.dart';
import '../sales/customers/customers_page.dart';
import '../sales/delivery_challans/delivery_challans_page.dart';
import '../sales/estimates/estimates_page.dart';
import '../sales/invoices/invoices_page.dart';
import '../sales/payment_received/payments_received_page.dart';
import '../sales/sales_order/sales_order_page.dart';

import '../sidebar/inventory/inventory_page.dart';
import '../sidebar/items_parts/items_parts_page.dart';

import '../reports/reports_page.dart';

import '../my_account/my_account_page.dart';

import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_body.dart';
import 'widgets/dashboard_nav_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // ================================================================
  // SIDEBAR STATE
  // ================================================================

  bool _isSidebarCollapsed = false;

  // ================================================================
  // CURRENT SELECTED MENU
  // ================================================================

  String selectedMenu = 'dashboard';

  // ================================================================
  // SIDEBAR COLLAPSE
  // ================================================================

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  // ================================================================
  // MENU SELECTION
  // ================================================================

  void _selectMenu(String menu) {
    setState(() {
      selectedMenu = menu;
    });
  }

  // ================================================================
  // SUPER ADMIN PROFILE CLICK
  // ================================================================

  void _openSuperAdminSettings() {
    setState(() {
      selectedMenu = 'all_settings';
    });
  }

  // ================================================================
  // BUILD SELECTED PAGE
  // ================================================================

  Widget _buildSelectedPage() {
    switch (selectedMenu.toLowerCase().trim()) {
      // ============================================================
      // ORGANIZATION
      // ============================================================

      case 'organization':
        return const OrganizationPage();

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
      // SUPER ADMIN SETTINGS
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
        return ItemsPartsPage(
          key: const ValueKey('items-page'),
          initialTab: 0,
          onSectionChanged: _selectMenu,
        );

      // ============================================================
      // PARTS
      // ============================================================

      case 'parts':
        return ItemsPartsPage(
          key: const ValueKey('parts-page'),
          initialTab: 1,
          onSectionChanged: _selectMenu,
        );

      // ============================================================
      // INVENTORY
      // ============================================================

      case 'inventory':
      case 'current stock':
      case 'current-stock':
        return InventoryPage(
          key: const ValueKey('current-stock-page'),
          initialTab: 0,
          onSectionChanged: _selectMenu,
        );

      case 'inventory adjustments':
      case 'inventory-adjustments':
        return InventoryPage(
          key: const ValueKey('inventory-adjustments-page'),
          initialTab: 1,
          onSectionChanged: _selectMenu,
        );

      case 'returnable assets':
      case 'returnable-assets':
        return InventoryPage(
          key: const ValueKey('returnable-assets-page'),
          initialTab: 2,
          onSectionChanged: _selectMenu,
        );

      // ============================================================
      // SALES
      // ============================================================

      case 'sales':
      case 'customers':
        return const CustomersPage();

      case 'estimates':
        return const EstimatesPage();

      case 'sales order':
      case 'sales-order':
        return const SalesOrderPage();

      case 'invoices':
        return const InvoicesPage();

      case 'delivery challans':
      case 'delivery-challans':
        return const DeliveryChallansPage();

      case 'payment received':
      case 'payment-received':
        return const PaymentsReceivedPage();

      case 'credit notes':
      case 'credit-notes':
        return const CreditNotesPage();

      // ============================================================
      // PURCHASE
      // ============================================================

      case 'purchase':
      case 'vendors':
        return const VendorsPage();

      case 'purchase orders':
      case 'purchase-orders':
        return const PurchaseOrdersPage();

      case 'bills':
        return const BillsPage();

      case 'payment made':
      case 'payment-made':
        return const PaymentsPage();

      case 'vendor credit notes':
      case 'vendor-credit-notes':
        return const VendorCreditNotesPage();

      // ============================================================
      // ACCOUNTANT
      // ============================================================

      case 'accountant':
      case 'expense':
      case 'expenses':
        return const ExpensesPage();

      case 'reimbursements':
        return const ReimbursementsPage();

      case 'travel allowance':
      case 'travel-allowance':
        return const TravelAllowancePage();

      case 'other claims':
      case 'other-claims':
        return const OtherClaimsPage();

      case 'investments':
        return const InvestmentPage();

      case 'loans':
        return const LoansPage();

      // ============================================================
      // FLUXA HUB
      // ============================================================

      case 'fluxa hub':
      case 'fluxa-hub':
        return _comingSoonPage(
          icon: Icons.hub_outlined,
          title: 'Fluxa Hub',
        );

      // ============================================================
      // SETTINGS
      // ============================================================

      case 'settings':
        return SettingsPage(
          onClose: () {
            setState(() {
              selectedMenu = 'dashboard';
            });
          },
        );

      // ============================================================
      // MY ACCOUNT
      // ============================================================

      case 'my account':
      case 'my-account':
        return const MyAccountPage();

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
  // COMING SOON PAGE
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
      appBar: DashboardAppBar(
        onMenuPressed: _toggleSidebar,
        onProfilePressed: _openSuperAdminSettings,
      ),
      body: Row(
        children: [
          // ==========================================================
          // PERMANENT SIDEBAR
          // ==========================================================

          DashboardNavBar(
            isCollapsed: _isSidebarCollapsed,
            selectedMenu: selectedMenu,
            onMenuSelected: _selectMenu,
          ),

          // ==========================================================
          // RIGHT SIDE PAGE CONTENT
          // ==========================================================

          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
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