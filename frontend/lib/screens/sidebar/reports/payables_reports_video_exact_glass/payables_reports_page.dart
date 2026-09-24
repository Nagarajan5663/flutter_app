import 'package:flutter/material.dart';

import 'ap_aging_summary_page.dart';
import 'bill_details_page.dart';
import 'payments_made_page.dart';
import 'vendor_balance_summary_page.dart';
import 'widgets/report_glass_widgets.dart';

enum _PayablesReport {
  apAgingSummary,
  vendorBalanceSummary,
  billDetails,
  paymentsMade,
}

class PayablesReportsPage extends StatefulWidget {
  final VoidCallback? onBackToAllReports;

  const PayablesReportsPage({
    super.key,
    this.onBackToAllReports,
  });

  @override
  State<PayablesReportsPage> createState() => _PayablesReportsPageState();
}

class _PayablesReportsPageState extends State<PayablesReportsPage> {
  _PayablesReport? selectedReport;

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
      case _PayablesReport.apAgingSummary:
        return ApAgingSummaryPage(
          onBack: _backToReports,
        );

      case _PayablesReport.vendorBalanceSummary:
        return VendorBalanceSummaryPage(
          onBack: _backToReports,
        );

      case _PayablesReport.billDetails:
        return BillDetailsPage(
          onBack: _backToReports,
        );

      case _PayablesReport.paymentsMade:
        return PaymentsMadePage(
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
            title: 'Payables Reports',
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
                    'Payables',
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
                  reportName: 'AP Aging Summary',
                  lastVisited: '10/10/2025 06:40 PM',
                  createdBy: 'System Generated',
                  onTap: () {
                    setState(() {
                      selectedReport = _PayablesReport.apAgingSummary;
                    });
                  },
                ),
                _ReportRow(
                  reportName: 'Vendor Balance Summary',
                  lastVisited: '-',
                  createdBy: 'System Generated',
                  onTap: () {
                    setState(() {
                      selectedReport = _PayablesReport.vendorBalanceSummary;
                    });
                  },
                ),
                _ReportRow(
                  reportName: 'Bill Details',
                  lastVisited: '04/05/2025 08:37 PM',
                  createdBy: 'System Generated',
                  onTap: () {
                    setState(() {
                      selectedReport = _PayablesReport.billDetails;
                    });
                  },
                ),
                _ReportRow(
                  reportName: 'Payments Made',
                  lastVisited: '10/05/2025 05:37 PM',
                  createdBy: 'System Generated',
                  showBottomBorder: false,
                  onTap: () {
                    setState(() {
                      selectedReport = _PayablesReport.paymentsMade;
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
