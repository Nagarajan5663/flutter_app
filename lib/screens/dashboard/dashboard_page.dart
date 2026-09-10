import 'package:flutter/material.dart';

import 'widgets/dashboard_app_bar.dart';
import 'widgets/dashboard_body.dart';
import 'widgets/dashboard_nav_bar.dart';

import '../reimbursements/reimbursements_page.dart';
import '../settings/settings_page.dart';
import '../sidebar/Accountant/expenses/expenses_page.dart';
import '../sidebar/Accountant/loans/loans_page.dart';
import '../sidebar/Accountant/other_claims/other_claims_page.dart';
import '../sidebar/Accountant/travel_allowance/travel_allowance_page.dart';
import '../sidebar/investment/investment_page.dart';
import '../sidebar/inventory/inventory_page.dart';
import '../sidebar/items_parts/items_parts_page.dart';
import '../sidebar/my_account/my_account_page.dart';
import '../sidebar/purchase/bills/bills_page.dart';
import '../sidebar/purchase/payments_made/payments_page.dart';
import '../sidebar/purchase/purchase_orders/purchase_orders_page.dart';
import '../sidebar/purchase/vendor_credit_notes/vendor_credit_notes_page.dart';
import '../sidebar/purchase/vendors/vendors_page.dart';
import '../sidebar/reports/reports_page.dart';
import '../sidebar/sales/credit_notes/credit_notes_page.dart';
import '../sidebar/sales/customer/customers_page.dart';
import '../sidebar/sales/delivery_challans/delivery_challans_page.dart';
import '../sidebar/sales/estimates/estimates_page.dart';
import '../sidebar/sales/invoices/invoices_page.dart';
import '../sidebar/sales/payments_received/payments_received_page.dart';
import '../sidebar/sales/sales_orders/sales_orders_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isSidebarCollapsed = false;
  String _selectedPage = 'dashboard';

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  void _changePage(String page) {
    setState(() {
      _selectedPage = page;
    });
  }

  Widget _buildPage() {
    switch (_selectedPage) {
      case 'dashboard':
        return const DashboardBody();

      case 'reports':
        return const ReportsPage();

      case 'items':
        return ItemsPartsPage(
          key: const ValueKey('items-page'),
          initialTab: 0,
          onSectionChanged: _changePage,
        );

      case 'parts':
        return ItemsPartsPage(
          key: const ValueKey('parts-page'),
          initialTab: 1,
          onSectionChanged: _changePage,
        );

      case 'current-stock':
        return InventoryPage(
          key: const ValueKey('current-stock-page'),
          initialTab: 0,
          onSectionChanged: _changePage,
        );

      case 'inventory-adjustments':
        return InventoryPage(
          key: const ValueKey('inventory-adjustments-page'),
          initialTab: 1,
          onSectionChanged: _changePage,
        );

      case 'returnable-assets':
        return InventoryPage(
          key: const ValueKey('returnable-assets-page'),
          initialTab: 2,
          onSectionChanged: _changePage,
        );

      case 'expenses':
      case 'expense':
        return const ExpensesPage();

      case 'reimbursements':
        return const ReimbursementsPage();

      case 'travel-allowance':
        return const TravelAllowancePage();

      case 'other-claims':
        return const OtherClaimsPage();

      case 'investments':
        return const InvestmentPage();

      case 'loans':
        return const LoansPage();

      case 'customers':
        return const CustomersPage();

      case 'estimates':
        return const EstimatesPage();

      case 'sales-order':
        return const SalesOrderPage();

      case 'invoices':
        return const InvoicesPage();

      case 'delivery-challans':
        return const DeliveryChallansPage();

      case 'payment-received':
        return const PaymentsReceivedPage();

      case 'credit-notes':
        return const CreditNotesPage();

      case 'vendors':
        return const VendorsPage();

      case 'purchase-orders':
        return const PurchaseOrdersPage();

      case 'bills':
        return const BillsPage();

      case 'payment-made':
        return const PaymentsPage();

      case 'vendor-credit-notes':
        return const VendorCreditNotesPage();

      case 'settings':
        return const SettingsPage();

      case 'my-account':
        return const MyAccountPage();

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
          DashboardNavBar(
            isCollapsed: _isSidebarCollapsed,
            onPageSelected: _changePage,
          ),
          Expanded(
            child: _buildPage(),
          ),
        ],
      ),
    );
  }
}