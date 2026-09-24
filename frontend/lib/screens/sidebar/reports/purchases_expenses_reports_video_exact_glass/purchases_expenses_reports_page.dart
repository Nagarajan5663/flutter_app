import 'package:flutter/material.dart';

import 'expense_details_page.dart';
import 'expenses_by_category_page.dart';
import 'purchases_by_item_page.dart';
import 'purchases_by_vendor_page.dart';
import 'widgets/report_glass_widgets.dart';

enum _PurchasesExpensesReport {
  purchasesByVendor,
  purchasesByItem,
  expenseDetails,
  expensesByCategory,
}

class PurchasesExpensesReportsPage extends StatefulWidget {
  final VoidCallback? onBackToAllReports;

  const PurchasesExpensesReportsPage({
    super.key,
    this.onBackToAllReports,
  });

  @override
  State<PurchasesExpensesReportsPage> createState() =>
      _PurchasesExpensesReportsPageState();
}

class _PurchasesExpensesReportsPageState
    extends State<PurchasesExpensesReportsPage> {
  _PurchasesExpensesReport? selectedReport;

  void _backToReports() {
    setState(() {
      selectedReport = null;
    });
  }

  void _backToAllReports() {
    if (widget.onBackToAllReports != null) {
      widget.onBackToAllReports!();
      return;
    }

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    switch (selectedReport) {
      case _PurchasesExpensesReport.purchasesByVendor:
        return PurchasesByVendorPage(
          onBack: _backToReports,
        );

      case _PurchasesExpensesReport.purchasesByItem:
        return PurchasesByItemPage(
          onBack: _backToReports,
        );

      case _PurchasesExpensesReport.expenseDetails:
        return ExpenseDetailsPage(
          onBack: _backToReports,
        );

      case _PurchasesExpensesReport.expensesByCategory:
        return ExpensesByCategoryPage(
          onBack: _backToReports,
        );

      case null:
        return _buildReportsList();
    }
  }

  Widget _buildReportsList() {
    return ReportGlassPageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportTitleActions(
            title: 'Purchases and Expenses',
            actions: [
              ReportGlassButton(
                label: 'Back to All Reports',
                icon: Icons.chevron_left_rounded,
                type: ReportGlassButtonType.back,
                onPressed: _backToAllReports,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ReportGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: Text(
                    'Purchases and Expenses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ReportGlassColors.navy,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.28),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.72),
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
                _ReportRow(
                  reportName: 'Purchases by Vendor',
                  lastVisited: '-',
                  createdBy: 'System Generated',
                  onTap: () {
                    setState(() {
                      selectedReport =
                          _PurchasesExpensesReport.purchasesByVendor;
                    });
                  },
                ),
                _ReportRow(
                  reportName: 'Purchases by Item',
                  lastVisited: '-',
                  createdBy: 'System Generated',
                  onTap: () {
                    setState(() {
                      selectedReport =
                          _PurchasesExpensesReport.purchasesByItem;
                    });
                  },
                ),
                _ReportRow(
                  reportName: 'Expense Details',
                  lastVisited: '-',
                  createdBy: 'System Generated',
                  onTap: () {
                    setState(() {
                      selectedReport =
                          _PurchasesExpensesReport.expenseDetails;
                    });
                  },
                ),
                _ReportRow(
                  reportName: 'Expenses by Category',
                  lastVisited: '-',
                  createdBy: 'System Generated',
                  showBottomBorder: false,
                  onTap: () {
                    setState(() {
                      selectedReport =
                          _PurchasesExpensesReport.expensesByCategory;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatefulWidget {
  final String reportName;
  final String lastVisited;
  final String createdBy;
  final VoidCallback onTap;
  final bool showBottomBorder;

  const _ReportRow({
    required this.reportName,
    required this.lastVisited,
    required this.createdBy,
    required this.onTap,
    this.showBottomBorder = true,
  });

  @override
  State<_ReportRow> createState() => _ReportRowState();
}

class _ReportRowState extends State<_ReportRow> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
            decoration: BoxDecoration(
              color: hovering
                  ? Colors.white.withValues(alpha: 0.30)
                  : Colors.transparent,
              border: widget.showBottomBorder
                  ? Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.60),
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    widget.reportName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2384B7),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.lastVisited,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334A5B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.createdBy,
                    style: const TextStyle(
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
