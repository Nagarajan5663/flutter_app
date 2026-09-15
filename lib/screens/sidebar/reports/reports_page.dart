import 'dart:ui';

import 'package:flutter/material.dart';

// ============================================================================
// BUSINESS OVERVIEW
// ============================================================================

import 'business_overview_reports/business_overview_page.dart';
import 'business_overview_reports/profit_loss_page.dart';
import 'business_overview_reports/cash_flow_statement_page.dart';
import 'business_overview_reports/balance_sheet_page.dart';

// ============================================================================
// SALES
// ============================================================================

import 'sales_reports/sales_reports_page.dart';
import 'sales_reports/sales_by_customer_page.dart';
import 'sales_reports/sales_by_item_page.dart';
import 'sales_reports/sales_by_sales_person_page.dart';
import 'sales_reports/sales_summary_page.dart';

// ============================================================================
// INVENTORY
// ============================================================================

import 'inventory_reports_video_exact_glass/inventory_reports/inventory_reports_page.dart';
import 'inventory_reports_video_exact_glass/inventory_reports/inventory_summary_page.dart';
import 'inventory_reports_video_exact_glass/inventory_reports/inventory_valuation_summary_page.dart';
import 'inventory_reports_video_exact_glass/inventory_reports/inventory_aging_summary_page.dart';

// ============================================================================
// RECEIVABLES
// ============================================================================

import 'receivables_reports_video_exact_glass/receivables_reports/receivables_reports_page.dart';
import 'receivables_reports_video_exact_glass/receivables_reports/ar_aging_summary_page.dart';
import 'receivables_reports_video_exact_glass/receivables_reports/ar_aging_details_page.dart';
import 'receivables_reports_video_exact_glass/receivables_reports/invoice_details_page.dart';
import 'receivables_reports_video_exact_glass/receivables_reports/customer_balance_summary_page.dart';

// ============================================================================
// PAYABLES
// ============================================================================

import 'payables_reports_video_exact_glass/payables_reports_page.dart';
import 'payables_reports_video_exact_glass/ap_aging_summary_page.dart';
import 'payables_reports_video_exact_glass/vendor_balance_summary_page.dart';
import 'payables_reports_video_exact_glass/bill_details_page.dart';
import 'payables_reports_video_exact_glass/payments_made_page.dart';

// ============================================================================
// PURCHASES AND EXPENSES
// ============================================================================

import 'purchases_expenses_reports_video_exact_glass/purchases_expenses_reports_page.dart';
import 'purchases_expenses_reports_video_exact_glass/purchases_by_vendor_page.dart';
import 'purchases_expenses_reports_video_exact_glass/purchases_by_item_page.dart';
import 'purchases_expenses_reports_video_exact_glass/expense_details_page.dart';
import 'purchases_expenses_reports_video_exact_glass/expenses_by_category_page.dart';

// ============================================================================
// ACCOUNTANT
// ============================================================================

import 'accountant_reports_video_exact_glass/accountant_reports_page.dart';
import 'accountant_reports_video_exact_glass/trial_balance_page.dart';

// ============================================================================
// REPORT DATA
// ============================================================================

class _ReportItem {
  final String name;
  final String? lastVisited;

  const _ReportItem({
    required this.name,
    this.lastVisited,
  });
}

class _ReportSectionData {
  final String title;
  final List<_ReportItem> reports;

  const _ReportSectionData({
    required this.title,
    required this.reports,
  });
}

// ============================================================================
// REPORTS PAGE
// ============================================================================

class ReportsPage extends StatefulWidget {
  const ReportsPage({
    super.key,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // ==========================================================================
  // CURRENT VIEW
  // ==========================================================================

  String _selectedCategory = 'All Reports';

  /// null = main Reports Center.
  String? _activeCategory;

  /// null = category list.
  /// Non-null = exact selected report page.
  String? _activeReport;

  // ==========================================================================
  // EXACT REPORT DATA FROM YOUR CURRENT REPORTS CENTER
  // ==========================================================================

  final List<_ReportSectionData> _sections = const [
    _ReportSectionData(
      title: 'Business Overview',
      reports: [
        _ReportItem(
          name: 'Profit and Loss',
          lastVisited: '04/05/2025 07:49 PM',
        ),
        _ReportItem(
          name: 'Profit and Loss (Schedule III)',
        ),
        _ReportItem(
          name: 'Horizontal Profit and Loss',
        ),
        _ReportItem(
          name: 'Cash Flow Statement',
          lastVisited: '24/03/2023 11:37 PM',
        ),
        _ReportItem(
          name: 'Balance Sheet',
          lastVisited: '14/07/2025 02:31 PM',
        ),
        _ReportItem(
          name: 'Horizontal Balance Sheet',
        ),
      ],
    ),

    _ReportSectionData(
      title: 'Sales',
      reports: [
        _ReportItem(name: 'Sales by Customer'),
        _ReportItem(name: 'Sales by Item'),
        _ReportItem(name: 'Sales by Sales Person'),
        _ReportItem(name: 'Sales Summary'),
      ],
    ),

    _ReportSectionData(
      title: 'Inventory',
      reports: [
        _ReportItem(name: 'Inventory Summary'),
        _ReportItem(name: 'Inventory Valuation Summary'),
        _ReportItem(name: 'Inventory Aging Summary'),
      ],
    ),

    _ReportSectionData(
      title: 'Receivables',
      reports: [
        _ReportItem(name: 'AR Aging Summary'),
        _ReportItem(name: 'AR Aging Details'),
        _ReportItem(name: 'Invoice Details'),
        _ReportItem(name: 'Customer Balance Summary'),
      ],
    ),

    _ReportSectionData(
      title: 'Payables',
      reports: [
        _ReportItem(name: 'AP Aging Summary'),
        _ReportItem(name: 'Vendor Balance Summary'),
        _ReportItem(name: 'Bill Details'),
        _ReportItem(name: 'Payments Made'),
      ],
    ),

    _ReportSectionData(
      title: 'Purchases and Expenses',
      reports: [
        _ReportItem(name: 'Purchases by Vendor'),
        _ReportItem(name: 'Purchases by Item'),
        _ReportItem(name: 'Expense Details'),
        _ReportItem(name: 'Expenses by Category'),
      ],
    ),

    _ReportSectionData(
      title: 'Accountant',
      reports: [
        _ReportItem(
          name: 'Account Transactions',
          lastVisited: '07/09/2026 07:10',
        ),
        _ReportItem(name: 'General Ledger'),
        _ReportItem(name: 'Journal Report'),
        _ReportItem(name: 'Trial Balance'),
      ],
    ),
  ];

  // ==========================================================================
  // CATEGORY NAVIGATION
  // ==========================================================================

  void _handleCategorySelected(String category) {
    if (category == 'All Reports') {
      _returnToAllReports();
      return;
    }

    setState(() {
      _selectedCategory = category;
      _activeCategory = category;
      _activeReport = null;
    });
  }

  void _returnToAllReports() {
    setState(() {
      _selectedCategory = 'All Reports';
      _activeCategory = null;
      _activeReport = null;
    });
  }

  void _backToCategory() {
    setState(() {
      _activeReport = null;
    });
  }

  // ==========================================================================
  // REPORT CLICK - OPENS EXACT REPORT PAGE
  // ==========================================================================

  void _openReport(
    String category,
    String reportName,
  ) {
    setState(() {
      _selectedCategory = category;
      _activeCategory = category;
      _activeReport = reportName;
    });
  }

  // ==========================================================================
  // CREATE CUSTOM REPORT
  // ==========================================================================

  void _createCustomReport() {
    // Your reference page shows this button but no custom-report form was
    // supplied in the current video/code, so no new screen is invented here.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create Custom Report selected'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    // Exact selected report page has first priority.
    if (_activeReport != null && _activeCategory != null) {
      return _buildExactReportPage(
        category: _activeCategory!,
        reportName: _activeReport!,
      );
    }

    // Category list page.
    if (_activeCategory != null) {
      return _buildCategoryPage(_activeCategory!);
    }

    // Main Reports Center.
    return _buildReportsCenter();
  }

  // ==========================================================================
  // CATEGORY PAGE ROUTING
  // ==========================================================================

  Widget _buildCategoryPage(String category) {
    switch (category) {
      case 'Business Overview':
        return BusinessOverviewPage(
          onBackToAllReports: _returnToAllReports,
        );

      case 'Sales':
        return SalesReportsPage(
          onBackToAllReports: _returnToAllReports,
        );

      case 'Inventory':
        return InventoryReportsPage(
          onBackToAllReports: _returnToAllReports,
        );

      case 'Receivables':
        return ReceivablesReportsPage(
          onBackToAllReports: _returnToAllReports,
        );

      case 'Payables':
        return PayablesReportsPage(
          onBackToAllReports: _returnToAllReports,
        );

      case 'Purchases and Expenses':
        return PurchasesExpensesReportsPage(
          onBackToAllReports: _returnToAllReports,
        );

      case 'Accountant':
        return AccountantReportsPage(
          onBackToAllReports: _returnToAllReports,
        );

      default:
        return _buildReportsCenter();
    }
  }

  // ==========================================================================
  // DIRECT REPORT ROUTING
  // ==========================================================================

  Widget _buildExactReportPage({
    required String category,
    required String reportName,
  }) {
    // ------------------------------------------------------------------------
    // BUSINESS OVERVIEW
    // ------------------------------------------------------------------------

    if (category == 'Business Overview') {
      switch (reportName) {
        case 'Profit and Loss':
          return ProfitLossPage(
            onBack: _backToCategory,
          );

        case 'Profit and Loss (Schedule III)':
          return ProfitLossScheduleIIIPage(
            onBack: _backToCategory,
          );

        case 'Horizontal Profit and Loss':
          return HorizontalProfitLossPage(
            onBack: _backToCategory,
          );

        case 'Cash Flow Statement':
          return CashFlowStatementPage(
            onBack: _backToCategory,
          );

        case 'Balance Sheet':
          return BalanceSheetPage(
            onBack: _backToCategory,
          );

        case 'Horizontal Balance Sheet':
          return HorizontalBalanceSheetPage(
            onBack: _backToCategory,
          );
      }
    }

    // ------------------------------------------------------------------------
    // SALES
    // ------------------------------------------------------------------------

    if (category == 'Sales') {
      switch (reportName) {
        case 'Sales by Customer':
          return SalesByCustomerPage(
            onBack: _backToCategory,
          );

        case 'Sales by Item':
          return SalesByItemPage(
            onBack: _backToCategory,
          );

        case 'Sales by Sales Person':
          return SalesBySalesPersonPage(
            onBack: _backToCategory,
          );

        case 'Sales Summary':
          return SalesSummaryPage(
            onBack: _backToCategory,
          );
      }
    }

    // ------------------------------------------------------------------------
    // INVENTORY
    // ------------------------------------------------------------------------

    if (category == 'Inventory') {
      switch (reportName) {
        case 'Inventory Summary':
          return InventorySummaryPage(
            onBack: _backToCategory,
          );

        case 'Inventory Valuation Summary':
          return InventoryValuationSummaryPage(
            onBack: _backToCategory,
          );

        case 'Inventory Aging Summary':
          return InventoryAgingSummaryPage(
            onBack: _backToCategory,
          );
      }
    }

    // ------------------------------------------------------------------------
    // RECEIVABLES
    // ------------------------------------------------------------------------

    if (category == 'Receivables') {
      switch (reportName) {
        case 'AR Aging Summary':
          return ArAgingSummaryPage(
            onBack: _backToCategory,
          );

        case 'AR Aging Details':
          return ArAgingDetailsPage(
            onBack: _backToCategory,
          );

        case 'Invoice Details':
          return InvoiceDetailsPage(
            onBack: _backToCategory,
          );

        case 'Customer Balance Summary':
          return CustomerBalanceSummaryPage(
            onBack: _backToCategory,
          );
      }
    }

    // ------------------------------------------------------------------------
    // PAYABLES
    // ------------------------------------------------------------------------

    if (category == 'Payables') {
      switch (reportName) {
        case 'AP Aging Summary':
          return ApAgingSummaryPage(
            onBack: _backToCategory,
          );

        case 'Vendor Balance Summary':
          return VendorBalanceSummaryPage(
            onBack: _backToCategory,
          );

        case 'Bill Details':
          return BillDetailsPage(
            onBack: _backToCategory,
          );

        case 'Payments Made':
          return PaymentsMadePage(
            onBack: _backToCategory,
          );
      }
    }

    // ------------------------------------------------------------------------
    // PURCHASES AND EXPENSES
    // ------------------------------------------------------------------------

    if (category == 'Purchases and Expenses') {
      switch (reportName) {
        case 'Purchases by Vendor':
          return PurchasesByVendorPage(
            onBack: _backToCategory,
          );

        case 'Purchases by Item':
          return PurchasesByItemPage(
            onBack: _backToCategory,
          );

        case 'Expense Details':
          return ExpenseDetailsPage(
            onBack: _backToCategory,
          );

        case 'Expenses by Category':
          return ExpensesByCategoryPage(
            onBack: _backToCategory,
          );
      }
    }

    // ------------------------------------------------------------------------
    // ACCOUNTANT
    // ------------------------------------------------------------------------

    if (category == 'Accountant') {
      switch (reportName) {
        case 'Trial Balance':
          return TrialBalancePage(
            onBack: _backToCategory,
          );

        // The reference Accountant video did not provide valid report screens
        // for these three rows. It showed server errors. We therefore do not
        // invent extra report content; clicking them opens the Accountant
        // category page where the original rows remain available.
        case 'Account Transactions':
        case 'General Ledger':
        case 'Journal Report':
          return AccountantReportsPage(
            onBackToAllReports: _returnToAllReports,
          );
      }
    }

    return _buildCategoryPage(category);
  }

  // ==========================================================================
  // MAIN REPORTS CENTER - SAME CONTENT + GLASSMORPHISM
  // ==========================================================================

  Widget _buildReportsCenter() {
    return LayoutBuilder(
      builder: (context, viewportConstraints) {
        final bool isMobile = viewportConstraints.maxWidth < 700;
        final bool enableTilt = viewportConstraints.maxWidth >= 850;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFCADAE7),
                Color(0xFFD2D6E3),
                Color(0xFFC7DCD9),
              ],
            ),
          ),
          child: Stack(
            children: [
              // ----------------------------------------------------------------
              // BACKGROUND ORBS
              // ----------------------------------------------------------------

              Positioned(
                top: -110,
                right: -70,
                child: IgnorePointer(
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF3984BA).withValues(alpha: 0.32),
                          const Color(0xFF3984BA).withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: -170,
                left: 20,
                child: IgnorePointer(
                  child: Container(
                    width: 440,
                    height: 440,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF7563AD).withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 270,
                left: -120,
                child: IgnorePointer(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF45B6A1).withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ----------------------------------------------------------------
              // CONTENT
              // ----------------------------------------------------------------

              SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 14 : 28),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: 1,
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (
                    context,
                    value,
                    animatedChild,
                  ) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          24 * (1 - value),
                        ),
                        child: animatedChild,
                      ),
                    );
                  },
                  child: _MainGlassTiltPanel(
                    enableTilt: enableTilt,
                    borderRadius: isMobile ? 20 : 28,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 18 : 28,
                        isMobile ? 22 : 30,
                        isMobile ? 18 : 28,
                        isMobile ? 22 : 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ====================================================
                          // HEADER
                          // ====================================================

                          _buildHeader(
                            isMobile: isMobile,
                          ),

                          const SizedBox(height: 28),

                          // ====================================================
                          // MAIN CONTENT
                          // ====================================================

                          LayoutBuilder(
                            builder: (
                              context,
                              constraints,
                            ) {
                              if (constraints.maxWidth >= 850) {
                                return Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 250,
                                      child: _GlassCategorySidebar(
                                        selectedCategory:
                                            _selectedCategory,
                                        categories: const [
                                          'All Reports',
                                          'Business Overview',
                                          'Sales',
                                          'Inventory',
                                          'Receivables',
                                          'Payables',
                                          'Purchases and Expenses',
                                          'Accountant',
                                        ],
                                        onCategorySelected:
                                            _handleCategorySelected,
                                      ),
                                    ),

                                    const SizedBox(width: 25),

                                    Expanded(
                                      child: Column(
                                        children: [
                                          for (
                                            int index = 0;
                                            index < _sections.length;
                                            index++
                                          ) ...[
                                            _GlassReportsSection(
                                              section: _sections[index],
                                              onReportSelected: (report) {
                                                _openReport(
                                                  _sections[index].title,
                                                  report.name,
                                                );
                                              },
                                            ),

                                            if (index !=
                                                _sections.length - 1)
                                              const SizedBox(height: 22),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _GlassCategorySidebar(
                                    selectedCategory:
                                        _selectedCategory,
                                    categories: const [
                                      'All Reports',
                                      'Business Overview',
                                      'Sales',
                                      'Inventory',
                                      'Receivables',
                                      'Payables',
                                      'Purchases and Expenses',
                                      'Accountant',
                                    ],
                                    onCategorySelected:
                                        _handleCategorySelected,
                                  ),

                                  const SizedBox(height: 22),

                                  for (
                                    int index = 0;
                                    index < _sections.length;
                                    index++
                                  ) ...[
                                    _GlassReportsSection(
                                      section: _sections[index],
                                      onReportSelected: (report) {
                                        _openReport(
                                          _sections[index].title,
                                          report.name,
                                        );
                                      },
                                    ),

                                    if (index != _sections.length - 1)
                                      const SizedBox(height: 20),
                                  ],
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 40),

                          const Center(
                            child: Text(
                              '© 2026 test. All Rights Reserved.',
                              style: TextStyle(
                                color: Color(0xFF718391),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader({
    required bool isMobile,
  }) {
    final title = Text(
      'Reports Center',
      style: TextStyle(
        color: const Color(0xFF123653),
        fontSize: isMobile ? 27 : 29,
        fontWeight: FontWeight.w700,
      ),
    );

    final button = _HoverPrimaryButton(
      onPressed: _createCustomReport,
      icon: Icons.add_rounded,
      label: 'Create Custom Report',
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 15),
          button,
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: title,
        ),
        button,
      ],
    );
  }
}

// ============================================================================
// MAIN GLASS TILT PANEL
// ============================================================================

class _MainGlassTiltPanel extends StatefulWidget {
  final Widget child;
  final bool enableTilt;
  final double borderRadius;

  const _MainGlassTiltPanel({
    required this.child,
    required this.enableTilt,
    required this.borderRadius,
  });

  @override
  State<_MainGlassTiltPanel> createState() =>
      _MainGlassTiltPanelState();
}

class _MainGlassTiltPanelState extends State<_MainGlassTiltPanel> {
  double rotateX = 0;
  double rotateY = 0;
  bool hovering = false;

  void _handleHover(PointerEvent event) {
    if (!widget.enableTilt) {
      return;
    }

    final RenderObject? object = context.findRenderObject();

    if (object is! RenderBox) {
      return;
    }

    final Size size = object.size;

    if (size.width == 0 || size.height == 0) {
      return;
    }

    final double x =
        (event.localPosition.dx / size.width) - 0.5;

    final double y =
        (event.localPosition.dy / size.height) - 0.5;

    const double tiltStrength = 0.025;

    setState(() {
      rotateY = x * tiltStrength;
      rotateX = -y * tiltStrength;
    });
  }

  void _resetTilt() {
    if (!mounted) {
      return;
    }

    setState(() {
      hovering = false;
      rotateX = 0;
      rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!widget.enableTilt) {
          return;
        }

        setState(() {
          hovering = true;
        });
      },
      onHover: _handleHover,
      onExit: (_) => _resetTilt(),
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: hovering ? 90 : 340,
        ),
        curve: hovering
            ? Curves.linear
            : Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(rotateX)
          ..rotateY(rotateY),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF173D59).withValues(
                alpha: hovering ? 0.18 : 0.10,
              ),
              blurRadius: hovering ? 50 : 35,
              spreadRadius: hovering ? 2 : 0,
              offset: Offset(
                rotateY * 120,
                14 + (rotateX * 80),
              ),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24,
              sigmaY: 24,
            ),
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 220,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: hovering ? 0.66 : 0.56,
                ),
                borderRadius:
                    BorderRadius.circular(
                  widget.borderRadius,
                ),
                border: Border.all(
                  width: 1.3,
                  color: Colors.white.withValues(
                    alpha:
                        hovering ? 0.95 : 0.78,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  widget.child,

                  Positioned(
                    top: -120,
                    right: -70,
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(
                                alpha:
                                    hovering ? 0.25 : 0.14,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS CATEGORY SIDEBAR
// ============================================================================

class _GlassCategorySidebar extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onCategorySelected;

  const _GlassCategorySidebar({
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              14,
            ),
            child: Text(
              'REPORT CATEGORY',
              style: TextStyle(
                color: Color(0xFF526A7B),
                fontSize: 11,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          for (final category in categories)
            _CategoryRow(
              label: category,
              selected: category == selectedCategory,
              onTap: () {
                onCategorySelected(category);
              },
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_CategoryRow> createState() =>
      _CategoryRowState();
}

class _CategoryRowState extends State<_CategoryRow> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 2,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: widget.selected
                  ? Colors.white.withValues(
                      alpha: 0.72,
                    )
                  : hovering
                      ? Colors.white.withValues(
                          alpha: 0.35,
                        )
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: widget.selected
                  ? Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.92,
                      ),
                    )
                  : null,
              boxShadow: widget.selected
                  ? [
                      BoxShadow(
                        color: const Color(
                          0xFF173D59,
                        ).withValues(
                          alpha: 0.07,
                        ),
                        blurRadius: 12,
                        offset:
                            const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 180),
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? const Color(
                            0xFF438CC0,
                          )
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.selected
                          ? const Color(
                              0xFF123456,
                            )
                          : const Color(
                              0xFF506778,
                            ),
                      fontSize: 13,
                      fontWeight: widget.selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GLASS REPORT SECTION
// ============================================================================

class _GlassReportsSection extends StatelessWidget {
  final _ReportSectionData section;
  final ValueChanged<_ReportItem> onReportSelected;

  const _GlassReportsSection({
    required this.section,
    required this.onReportSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              17,
            ),
            child: Text(
              section.title,
              style: const TextStyle(
                color: Color(0xFF123653),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.28,
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(
                    alpha: 0.72,
                  ),
                ),
                bottom: BorderSide(
                  color: Colors.white.withValues(
                    alpha: 0.72,
                  ),
                ),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'REPORT NAME',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF667986),
                    ),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Text(
                    'LAST VISITED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF667986),
                    ),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Text(
                    'CREATED BY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF667986),
                    ),
                  ),
                ),
              ],
            ),
          ),

          for (int index = 0;
              index < section.reports.length;
              index++)
            _GlassReportRow(
              report: section.reports[index],
              showBottomBorder:
                  index != section.reports.length - 1,
              onTap: () {
                onReportSelected(
                  section.reports[index],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _GlassReportRow extends StatefulWidget {
  final _ReportItem report;
  final VoidCallback onTap;
  final bool showBottomBorder;

  const _GlassReportRow({
    required this.report,
    required this.onTap,
    required this.showBottomBorder,
  });

  @override
  State<_GlassReportRow> createState() =>
      _GlassReportRowState();
}

class _GlassReportRowState
    extends State<_GlassReportRow> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration:
                const Duration(milliseconds: 180),
            transform: Matrix4.translationValues(
              hovering ? 3 : 0,
              0,
              0,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: hovering
                  ? Colors.white.withValues(
                      alpha: 0.34,
                    )
                  : Colors.transparent,
              border: widget.showBottomBorder
                  ? Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(
                          alpha: 0.58,
                        ),
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    widget.report.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: hovering
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: const Color(
                        0xFF2384B7,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 3,
                  child: Text(
                    widget.report.lastVisited ?? '-',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334A5B),
                    ),
                  ),
                ),

                const Expanded(
                  flex: 3,
                  child: Text(
                    'System Generated',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334A5B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// GENERIC GLASS CARD
// ============================================================================

class _GlassCard extends StatefulWidget {
  final Widget child;

  const _GlassCard({
    required this.child,
  });

  @override
  State<_GlassCard> createState() =>
      _GlassCardState();
}

class _GlassCardState extends State<_GlassCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 220),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: hovering ? 0.46 : 0.33,
          ),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: hovering ? 0.95 : 0.72,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF163E5A)
                  .withValues(
                alpha: hovering ? 0.11 : 0.05,
              ),
              blurRadius: hovering ? 28 : 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: widget.child,
        ),
      ),
    );
  }
}

// ============================================================================
// CREATE CUSTOM REPORT BUTTON
// ============================================================================

class _HoverPrimaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _HoverPrimaryButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  State<_HoverPrimaryButton> createState() =>
      _HoverPrimaryButtonState();
}

class _HoverPrimaryButtonState
    extends State<_HoverPrimaryButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovering = false;
        });
      },
      child: AnimatedScale(
        duration:
            const Duration(milliseconds: 170),
        scale: hovering ? 1.025 : 1,
        curve: Curves.easeOutCubic,
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(
            widget.icon,
            size: 18,
          ),
          label: Text(widget.label),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF2B76A8),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Colors.white.withValues(
                  alpha: 0.35,
                ),
              ),
            ),
            shadowColor:
                const Color(0xFF174D72),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
