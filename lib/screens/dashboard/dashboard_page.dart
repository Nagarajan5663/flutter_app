import 'package:flutter/material.dart';

// ================================================================
// DASHBOARD WIDGETS
// ================================================================

import 'widgets/dashboard_nav_bar.dart';
import 'widgets/dashboard_body.dart';

// ================================================================
// SIDEBAR MODULES
// ================================================================

// Items & Parts
import '../sidebar/items_parts/items_parts_page.dart';

// Inventory
import '../sidebar/inventory/inventory_page.dart';

// Settings
import '../settings/settings_page.dart';

// Expenses
import '../sidebar/Accountant/expenses/expenses_page.dart';

// Travel Allowance
import '../sidebar/Accountant/travel_allowance/travel_allowance_page.dart';

// Loans
import '../sidebar/Accountant/loans/loans_page.dart';

// Reimbursements
import '../reimbursements/reimbursements_page.dart';

// Other Claims
import '../sidebar/Accountant/other_claims/other_claims_page.dart';

// Investments
import '../sidebar/investment/investment_page.dart';

// Sales - Customers
import '../sidebar/sales/customer/customers_page.dart';

// Sales - Estimates
import '../sidebar/sales/estimates/estimates_page.dart';

// Sales - Sales Order
import '../sidebar/sales/sales_orders/sales_orders_page.dart';

// Sales - Invoices
import '../sidebar/sales/invoices/invoices_page.dart';

// Sales - Delivery Challans
import '../sidebar/sales/delivery_challans/delivery_challans_page.dart';

// Sales - Payment Received
import '../sidebar/sales/payments_received/payments_received_page.dart';

// Sales - Credit Notes
import '../sidebar/sales/credit_notes/credit_notes_page.dart';

// Purchase - Vendors
import '../sidebar/purchase/vendors/vendors_page.dart';

// Purchase - Purchase Orders
import '../sidebar/purchase/purchase_orders/purchase_orders_page.dart';

// Purchase - Bills
import '../sidebar/purchase/bills/bills_page.dart';

// Purchase - Payment Made
import '../sidebar/purchase/payments_made/payments_page.dart';

// Purchase - Vendor Credit Notes
import '../sidebar/purchase/vendor_credit_notes/vendor_credit_notes_page.dart';

// My Account
import '../sidebar/my_account/my_account_page.dart';

// ================================================================
// DASHBOARD PAGE
// ================================================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

// ================================================================
// DASHBOARD PAGE STATE
// ================================================================

class _DashboardPageState extends State<DashboardPage> {
  // ==============================================================
  // SELECTED SIDEBAR MENU
  // ==============================================================

  String selectedMenu = 'Dashboard';

  // ==============================================================
  // CHANGE SELECTED MENU
  // ==============================================================

  void _selectMenu(String menu) {
    if (selectedMenu == menu) {
      return;
    }

    setState(() {
      selectedMenu = menu;
    });
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ========================================================
          // PERMANENT SIDEBAR
          // ========================================================

          DashboardNavBar(
            selectedMenu: selectedMenu,
            onMenuSelected: _selectMenu,
          ),

          // ========================================================
          // MAIN CONTENT AREA
          // ========================================================

          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // CONTENT ROUTING
  // ==============================================================

  Widget _buildContent() {
    switch (selectedMenu) {
      // ============================================================
      // DASHBOARD
      // ============================================================

      case 'Dashboard':
        // IMPORTANT:
        // DO NOT USE HomePage HERE.
        //
        // This displays your actual dashboard UI:
        // Cash Flow Overview
        // Summary Cards
        // Profit & Loss
        // Inventory Overview
        // Recent Activity
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
      // INVENTORY - CURRENT STOCK
      // ============================================================

      case 'Current Stock':
        return InventoryPage(
          key: const ValueKey('current-stock-page'),
          initialTab: 0,
          onSectionChanged: _selectMenu,
        );

      // ============================================================
      // INVENTORY - INVENTORY ADJUSTMENTS
      // ============================================================

      case 'Inventory Adjustments':
        return InventoryPage(
          key: const ValueKey('inventory-adjustments-page'),
          initialTab: 1,
          onSectionChanged: _selectMenu,
        );

      // ============================================================
      // INVENTORY - RETURNABLE ASSETS
      // ============================================================

      case 'Returnable Assets':
        return InventoryPage(
          key: const ValueKey('returnable-assets-page'),
          initialTab: 2,
          onSectionChanged: _selectMenu,
        );

      // ============================================================
      // ACCOUNTANT - EXPENSES
      // ============================================================

      case 'Expense':
      case 'Expenses':
        return const ExpensesPage();

      // ============================================================
      // ACCOUNTANT - REIMBURSEMENTS
      // ============================================================

      case 'Reimbursements':
        return const ReimbursementsPage();

      // ============================================================
      // ACCOUNTANT - TRAVEL ALLOWANCE
      // ============================================================

      case 'Travel Allowance':
        return const TravelAllowancePage();

      // ============================================================
      // ACCOUNTANT - OTHER CLAIMS
      // ============================================================

      case 'Other Claims':
        return const OtherClaimsPage();

      // ============================================================
      // ACCOUNTANT - INVESTMENTS
      // ============================================================

      case 'Investments':
        return const InvestmentPage();

      // ============================================================
      // ACCOUNTANT - LOANS
      // ============================================================

      case 'Loans':
        return const LoansPage();

      // ============================================================
      // SALES - CUSTOMERS
      // ============================================================

      case 'Customers':
        return const CustomersPage();

      // ============================================================
      // SALES - ESTIMATES
      // ============================================================

      case 'Estimates':
        return const EstimatesPage();

      // ============================================================
      // SALES - SALES ORDER
      // ============================================================

      case 'Sales Order':
        return const SalesOrderPage();

      // ============================================================
      // SALES - INVOICES
      // ============================================================

      case 'Invoices':
        return const InvoicesPage();

      // ============================================================
      // SALES - DELIVERY CHALLANS
      // ============================================================

      case 'Delivery Challans':
        return const DeliveryChallansPage();

      // ============================================================
      // SALES - PAYMENT RECEIVED
      // ============================================================

      case 'Payment Received':
        return const PaymentsReceivedPage();

      // ============================================================
      // SALES - CREDIT NOTES
      // ============================================================

      case 'Credit Notes':
        return const CreditNotesPage();

      // ============================================================
      // PURCHASE - VENDORS
      // ============================================================

      case 'Vendors':
        return const VendorsPage();

      // ============================================================
      // PURCHASE - PURCHASE ORDERS
      // ============================================================

      case 'Purchase Orders':
        return const PurchaseOrdersPage();

      // ============================================================
      // PURCHASE - BILLS
      // ============================================================

      case 'Bills':
        return const BillsPage();

      // ============================================================
      // PURCHASE - PAYMENT MADE
      // ============================================================

      case 'Payment Made':
        return const PaymentsPage();

      // ============================================================
      // PURCHASE - VENDOR CREDIT NOTES
      // ============================================================

      case 'Vendor Credit Notes':
        return const VendorCreditNotesPage();

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
      // FAQ
      // ============================================================

      case "FAQ's":
      case 'FAQs':
        return _comingSoon(
          "FAQ's",
          Icons.question_answer,
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

  // ==============================================================
  // COMING SOON PAGE
  // ==============================================================

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
          width: 420,
          padding: const EdgeInsets.all(40),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(14),

            border: Border.all(
              color: const Color(0xFFD9DEE5),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
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
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17395C),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'This module is coming soon.',
                textAlign: TextAlign.center,
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