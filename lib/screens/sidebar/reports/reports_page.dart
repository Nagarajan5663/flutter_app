import 'package:flutter/material.dart';

import 'business_overview_page.dart';

import 'widgets/report_category_sidebar.dart';
import 'widgets/reports_section.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() =>
      _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // ================================================================
  // SELECTED CATEGORY
  // ================================================================

  String _selectedCategory = 'All Reports';

  // ================================================================
  // BUSINESS OVERVIEW DETAIL PAGE
  // ================================================================

  bool _showBusinessOverview = false;

  // ================================================================
  // REPORT DATA
  // ================================================================

  final List<ReportSectionData> _sections = const [
    // ==============================================================
    // BUSINESS OVERVIEW
    // ==============================================================

    ReportSectionData(
      title: 'Business Overview',
      reports: [
        ReportItem(
          name: 'Profit and Loss',
          lastVisited: '04/05/2025 07:49 PM',
        ),

        ReportItem(
          name: 'Profit and Loss (Schedule III)',
        ),

        ReportItem(
          name: 'Horizontal Profit and Loss',
        ),

        ReportItem(
          name: 'Cash Flow Statement',
          lastVisited: '24/03/2023 11:37 PM',
        ),

        ReportItem(
          name: 'Balance Sheet',
          lastVisited: '14/07/2025 02:31 PM',
        ),

        ReportItem(
          name: 'Horizontal Balance Sheet',
        ),
      ],
    ),

    // ==============================================================
    // SALES
    // ==============================================================

    ReportSectionData(
      title: 'Sales',
      reports: [
        ReportItem(
          name: 'Sales by Customer',
        ),

        ReportItem(
          name: 'Sales by Item',
        ),

        ReportItem(
          name: 'Sales by Sales Person',
        ),

        ReportItem(
          name: 'Sales Summary',
        ),
      ],
    ),

    // ==============================================================
    // INVENTORY
    // ==============================================================

    ReportSectionData(
      title: 'Inventory',
      reports: [
        ReportItem(
          name: 'Inventory Summary',
        ),

        ReportItem(
          name: 'Inventory Valuation Summary',
        ),

        ReportItem(
          name: 'Inventory Aging Summary',
        ),
      ],
    ),

    // ==============================================================
    // RECEIVABLES
    // ==============================================================

    ReportSectionData(
      title: 'Receivables',
      reports: [
        ReportItem(
          name: 'AR Aging Summary',
        ),

        ReportItem(
          name: 'AR Aging Details',
        ),

        ReportItem(
          name: 'Invoice Details',
        ),

        ReportItem(
          name: 'Customer Balance Summary',
        ),
      ],
    ),

    // ==============================================================
    // PAYABLES
    // ==============================================================

    ReportSectionData(
      title: 'Payables',
      reports: [
        ReportItem(
          name: 'AP Aging Summary',
        ),

        ReportItem(
          name: 'Vendor Balance Summary',
        ),

        ReportItem(
          name: 'Bill Details',
        ),

        ReportItem(
          name: 'Payments Made',
        ),
      ],
    ),

    // ==============================================================
    // PURCHASES AND EXPENSES
    // ==============================================================

    ReportSectionData(
      title: 'Purchases and Expenses',
      reports: [
        ReportItem(
          name: 'Purchases by Vendor',
        ),

        ReportItem(
          name: 'Purchases by Item',
        ),

        ReportItem(
          name: 'Expense Details',
        ),

        ReportItem(
          name: 'Expenses by Category',
        ),
      ],
    ),

    // ==============================================================
    // ACCOUNTANT
    // ==============================================================

    ReportSectionData(
      title: 'Accountant',
      reports: [
        ReportItem(
          name: 'Account Transactions',
          lastVisited: '07/09/2026 07:10',
        ),

        ReportItem(
          name: 'General Ledger',
        ),

        ReportItem(
          name: 'Journal Report',
        ),

        ReportItem(
          name: 'Trial Balance',
        ),
      ],
    ),
  ];

  // ================================================================
  // FILTER REPORT SECTIONS
  // ================================================================

  List<ReportSectionData> get _visibleSections {
    if (_selectedCategory == 'All Reports') {
      return _sections;
    }

    return _sections
        .where(
          (section) =>
              section.title == _selectedCategory,
        )
        .toList();
  }

  // ================================================================
  // CATEGORY CLICK
  // ================================================================

  void _handleCategorySelected(String category) {
    // Business Overview opens a NEW DETAIL VIEW
    if (category == 'Business Overview') {
      setState(() {
        _showBusinessOverview = true;
      });

      return;
    }

    // Other categories filter the reports center
    setState(() {
      _selectedCategory = category;
    });
  }

  // ================================================================
  // CUSTOM REPORT BUTTON
  // ================================================================

  void _createCustomReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Create Custom Report selected',
        ),
      ),
    );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    // ==============================================================
    // BUSINESS OVERVIEW DETAIL PAGE
    // ==============================================================

    if (_showBusinessOverview) {
      return BusinessOverviewPage(
        onBack: () {
          setState(() {
            _showBusinessOverview = false;
            _selectedCategory = 'All Reports';
          });
        },
      );
    }

    // ==============================================================
    // REPORTS CENTER
    // ==============================================================

    return Container(
      width: double.infinity,
      height: double.infinity,

      color: const Color(0xFFF3F7FA),

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          28,
          28,
          28,
          40,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =======================================================
            // REPORTS CENTER HEADER
            // =======================================================

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 600) {
                  return Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Reports Center',
                          style: TextStyle(
                            color: Color(0xFF123653),
                            fontSize: 29,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: _createCustomReport,

                        icon: const Icon(
                          Icons.add,
                          size: 18,
                        ),

                        label: const Text(
                          'Create Custom Report',
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF5DAEDD),

                          foregroundColor: Colors.white,

                          elevation: 0,

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),

                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reports Center',
                      style: TextStyle(
                        color: Color(0xFF123653),
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton.icon(
                      onPressed: _createCustomReport,

                      icon: const Icon(Icons.add),

                      label: const Text(
                        'Create Custom Report',
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // =======================================================
            // REPORT BODY
            // =======================================================

            LayoutBuilder(
              builder: (context, constraints) {
                // ===================================================
                // WEB / DESKTOP
                // ===================================================

                if (constraints.maxWidth >= 850) {
                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =============================================
                      // CATEGORY SIDEBAR
                      // =============================================

                      SizedBox(
                        width: 250,

                        child: ReportCategorySidebar(
                          selectedCategory:
                              _selectedCategory,

                          onCategorySelected:
                              _handleCategorySelected,
                        ),
                      ),

                      const SizedBox(width: 25),

                      // =============================================
                      // REPORT SECTIONS
                      // =============================================

                      Expanded(
                        child: Column(
                          children: [
                            for (int i = 0;
                                i <
                                    _visibleSections
                                        .length;
                                i++) ...[
                              ReportsSection(
                                section:
                                    _visibleSections[i],

                                onReportSelected:
                                    (report) {
                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${report.name} selected',
                                      ),
                                      duration:
                                          const Duration(
                                        seconds: 1,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              if (i !=
                                  _visibleSections
                                          .length -
                                      1)
                                const SizedBox(
                                  height: 22,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                }

                // ===================================================
                // TABLET / MOBILE
                // ===================================================

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    ReportCategorySidebar(
                      selectedCategory:
                          _selectedCategory,

                      onCategorySelected:
                          _handleCategorySelected,
                    ),

                    const SizedBox(height: 22),

                    for (int i = 0;
                        i < _visibleSections.length;
                        i++) ...[
                      ReportsSection(
                        section:
                            _visibleSections[i],

                        onReportSelected:
                            (report) {
                          ScaffoldMessenger.of(
                                  context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                '${report.name} selected',
                              ),
                            ),
                          );
                        },
                      ),

                      if (i !=
                          _visibleSections.length -
                              1)
                        const SizedBox(height: 20),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // =======================================================
            // FOOTER
            // =======================================================

            const Center(
              child: Text(
                '© 2026 test. All Rights Reserved.',
                style: TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}