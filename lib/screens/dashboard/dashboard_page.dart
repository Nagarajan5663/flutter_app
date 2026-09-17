import 'package:flutter/material.dart';

// ================================================================
// DASHBOARD WIDGETS
// ================================================================

import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_nav_bar.dart';
import 'widgets/dashboard_body.dart';

// ================================================================
// SALES
// ================================================================

import '../sidebar/sales/customer/customers_page.dart';
import '../sidebar/sales/estimates/estimates_page.dart';
import '../sidebar/sales/sales_orders/sales_orders_page.dart';
import '../sidebar/sales/invoices/invoices_page.dart';
import '../sidebar/sales/delivery_challans/delivery_challans_page.dart';
import '../sidebar/sales/payments_received/payments_received_page.dart';
import '../sidebar/sales/credit_notes/credit_notes_page.dart';

// ================================================================
// SETTINGS
// ================================================================

// Sidebar Settings -> Preferences page
import '../sidebar/settings/preferences_page.dart';

// Super Admin -> All Settings
import '../organization/organization_page.dart';

// ================================================================
// REPORTS
// ================================================================

import '../sidebar/reports/reports_page.dart';

// ================================================================
// ITEMS & PARTS
// ================================================================

import '../sidebar/items_parts/items_parts_page.dart';

// ================================================================
// INVENTORY
// ================================================================

import '../sidebar/inventory/inventory_page.dart';

// ================================================================
// PURCHASE
// ================================================================

import '../sidebar/purchase/vendors/vendors_page.dart';
import '../sidebar/purchase/purchase_orders/purchase_orders_page.dart';
import '../sidebar/purchase/bills/bills_page.dart';
import '../sidebar/purchase/payments_made/payments_made_page.dart';
import '../sidebar/purchase/vendor_credit_notes/vendor_credit_notes_page.dart';

// ================================================================
// ACCOUNTANT
// ================================================================

import '../sidebar/accountant/expenses/expenses_page.dart';
import '../sidebar/accountant/reimbursements/reimbursements_page.dart';
import '../sidebar/accountant/travel_allowance/travel_allowance_page.dart';
import '../sidebar/accountant/other_claims/other_claims_page.dart';
import '../sidebar/accountant/loans/loans_page.dart';
import '../sidebar/my_account/my_account_page.dart';

// ================================================================
// INVESTMENT
// ================================================================

import '../sidebar/accountant/investment/investment_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
  });

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
  // TOGGLE SIDEBAR
  // ================================================================

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  // ================================================================
  // SELECT SIDEBAR MENU
  // ================================================================

  void _selectMenu(String menu) {
    setState(() {
      selectedMenu = menu;
    });
  }

  // ================================================================
  // OPEN SUPER ADMIN -> ALL SETTINGS
  // ================================================================

  void _openAllSettings() {
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
      // DASHBOARD
      // ============================================================

      case 'dashboard':
        return const DashboardBody();

      // ============================================================
      // SIDEBAR SETTINGS
      // ============================================================

      case 'settings':
        return PreferencesPage(
          onBack: () {
            setState(() {
              selectedMenu = 'dashboard';
            });
          },
        );

      // ============================================================
      // SUPER ADMIN -> ALL SETTINGS
      // ============================================================

      case 'all_settings':
        return OrganizationPage(
          onBack: () {
            setState(() {
              selectedMenu = 'dashboard';
            });
          },
        );

      // ============================================================
      // ORGANIZATION
      // ============================================================

      case 'organization':
        return OrganizationPage(
          onBack: () {
            setState(() {
              selectedMenu = 'dashboard';
            });
          },
        );

      // ============================================================
      // REPORTS
      // ============================================================

      case 'reports':
        return const ReportsPage();

      // ============================================================
      // ITEMS & PARTS
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
      case 'customers':
        return const CustomersPage();

      case 'estimates':
        return const EstimatesPage();

      case 'sales order':
      case 'sales orders':
        return const SalesOrderPage();

      case 'invoices':
        return const InvoicesPage();

      case 'delivery challans':
        return const DeliveryChallansPage();

      case 'payment received':
      case 'payments received':
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
      case 'payments made':
        return const PaymentsMadePage();

      case 'vendor credit notes':
        return const VendorCreditNotesPage();

      // ============================================================
      // ACCOUNTANT
      // ============================================================

      case 'accountant':
        return const ExpensesPage();

      case 'expense':
      case 'expenses':
        return const ExpensesPage();

      case 'reimbursements':
        return const ReimbursementsPage();

      case 'travel allowance':
        return const TravelAllowancePage();

      case 'other claims':
        return const OtherClaimsPage();

      case 'investments':
      case 'investment':
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
      color: const Color(
        0xFFF4F7FA,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: const Color(
                0xFF245AA6,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              title,
              style: const TextStyle(
                color: Color(
                  0xFF123653,
                ),
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Coming Soon',
              style: TextStyle(
                color: Color(
                  0xFF7A8791,
                ),
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
    if (selectedMenu == 'all_settings') {
      return OrganizationPage(
        onBack: () {
          setState(() {
            selectedMenu = 'dashboard';
          });
        },
      );
    }

    return Scaffold(
      // ============================================================
      // TOP APP BAR
      // ============================================================

      appBar: DashboardAppBar(
        onMenuPressed: _toggleSidebar,

        // Super Admin click -> All Settings
        onProfilePressed: _openAllSettings,
      ),

      // ============================================================
      // SIDEBAR + PAGE CONTENT
      // ============================================================

      body: Row(
        children: [
          // ========================================================
          // LEFT SIDEBAR
          // ========================================================

          DashboardNavBar(
            isCollapsed: _isSidebarCollapsed,
            selectedMenu: selectedMenu,
            onMenuSelected: _selectMenu,
          ),

          // ========================================================
          // RIGHT PAGE CONTENT
          // ========================================================

          Expanded(
            child: _buildSelectedPage(),
          ),
        ],
      ),
    );
  }
}