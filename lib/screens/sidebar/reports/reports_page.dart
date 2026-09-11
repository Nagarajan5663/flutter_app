import 'package:flutter/material.dart';

import 'report_category_detail_page.dart';
import 'widgets/report_category_sidebar.dart';
import 'widgets/reports_section.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // ================================================================
  // CURRENT CATEGORY
  // ================================================================

  String _selectedCategory = 'All Reports';

  // null = main Reports Center
  // otherwise = selected category detail page
  String? _activeCategory;

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
  // POINT 5 - FIND SELECTED CATEGORY DATA
  // ================================================================

  ReportSectionData? get _activeSection {
    if (_activeCategory == null) {
      return null;
    }

    for (final section in _sections) {
      if (section.title == _activeCategory) {
        return section;
      }
    }

    return null;
  }

  // ================================================================
  // CATEGORY CLICK
  // ================================================================

  void _handleCategorySelected(String category) {
    // All Reports returns to main Reports Center
    if (category == 'All Reports') {
      setState(() {
        _selectedCategory = 'All Reports';
        _activeCategory = null;
      });

      return;
    }

    // Every other category opens full body
    setState(() {
      _selectedCategory = category;
      _activeCategory = category;
    });
  }

  // ================================================================
  // CREATE CUSTOM REPORT
  // ================================================================

  void _createCustomReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Create Custom Report selected',
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // ================================================================
  // REPORT CLICK
  // ================================================================

  void _handleReportSelected(
    BuildContext context,
    ReportItem report,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${report.name} selected',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ================================================================
  // POINT 6 - BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final ReportSectionData? activeSection =
        _activeSection;

    // ==============================================================
    // CATEGORY DETAIL PAGE
    // ==============================================================

    if (activeSection != null) {
      return ReportCategoryDetailPage(
        section: activeSection,

        // ============================================================
        // BACK TO ALL REPORTS
        // ============================================================

        onBack: () {
          setState(() {
            _activeCategory = null;
            _selectedCategory = 'All Reports';
          });
        },

        // ============================================================
        // REPORT ROW CLICK
        // ============================================================

        onReportSelected: (report) {
          _handleReportSelected(
            context,
            report,
          );
        },
      );
    }

    // ==============================================================
    // MAIN REPORTS CENTER
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
            // ========================================================
            // HEADER
            // ========================================================

            LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                // ====================================================
                // DESKTOP
                // ====================================================

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

                      // =================================================
                      // CREATE CUSTOM REPORT
                      //
                      // ONLY SHOWS ON ALL REPORTS PAGE
                      // =================================================

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

                          foregroundColor:
                              Colors.white,

                          elevation: 0,

                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),

                          shape:
                              RoundedRectangleBorder(
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

                // ====================================================
                // MOBILE
                // ====================================================

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
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Create Custom Report',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF5DAEDD),
                        foregroundColor:
                            Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // ========================================================
            // MAIN REPORT CONTENT
            // ========================================================

            LayoutBuilder(
              builder: (
                context,
                constraints,
              ) {
                // ====================================================
                // WEB / DESKTOP
                // ====================================================

                if (constraints.maxWidth >= 850) {
                  return Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ===============================================
                      // LEFT REPORT CATEGORY
                      // ===============================================

                      SizedBox(
                        width: 250,

                        child:
                            ReportCategorySidebar(
                          selectedCategory:
                              _selectedCategory,

                          onCategorySelected:
                              _handleCategorySelected,
                        ),
                      ),

                      const SizedBox(width: 25),

                      // ===============================================
                      // ALL REPORT SECTIONS
                      // ===============================================

                      Expanded(
                        child: Column(
                          children: [
                            for (
                              int index = 0;
                              index <
                                  _sections.length;
                              index++
                            ) ...[
                              ReportsSection(
                                section:
                                    _sections[index],

                                onReportSelected:
                                    (report) {
                                  _handleReportSelected(
                                    context,
                                    report,
                                  );
                                },
                              ),

                              if (index !=
                                  _sections.length -
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

                // ====================================================
                // TABLET / MOBILE
                // ====================================================

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // CATEGORY
                    // =================================================

                    ReportCategorySidebar(
                      selectedCategory:
                          _selectedCategory,

                      onCategorySelected:
                          _handleCategorySelected,
                    ),

                    const SizedBox(height: 22),

                    // =================================================
                    // REPORT SECTIONS
                    // =================================================

                    for (
                      int index = 0;
                      index < _sections.length;
                      index++
                    ) ...[
                      ReportsSection(
                        section:
                            _sections[index],

                        onReportSelected:
                            (report) {
                          _handleReportSelected(
                            context,
                            report,
                          );
                        },
                      ),

                      if (index !=
                          _sections.length - 1)
                        const SizedBox(
                          height: 20,
                        ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // ========================================================
            // FOOTER
            // ========================================================

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