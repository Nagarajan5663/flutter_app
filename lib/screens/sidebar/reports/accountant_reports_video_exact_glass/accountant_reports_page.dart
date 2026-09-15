import 'package:flutter/material.dart';

import 'trial_balance_page.dart';
import 'widgets/report_glass_widgets.dart';

enum _AccountantReport {
  accountTransactions,
  generalLedger,
  journalReport,
  trialBalance,
}

class AccountantReportsPage extends StatefulWidget {
  final VoidCallback? onBackToAllReports;

  /// The uploaded video does not show valid in-app report pages for
  /// Account Transactions, General Ledger, or Journal Report.
  /// Those links return a server error in the reference video.
  ///
  /// To avoid inventing content, the three rows stay on this page by
  /// default. If your project already has those pages, you may use this
  /// callback to route to them.
  final ValueChanged<String>? onUnavailableReportTap;

  const AccountantReportsPage({
    super.key,
    this.onBackToAllReports,
    this.onUnavailableReportTap,
  });

  @override
  State<AccountantReportsPage> createState() =>
      _AccountantReportsPageState();
}

class _AccountantReportsPageState extends State<AccountantReportsPage> {
  _AccountantReport? selectedReport;

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

  void _handleUnavailable(String reportName) {
    widget.onUnavailableReportTap?.call(reportName);
  }

  @override
  Widget build(BuildContext context) {
    if (selectedReport == _AccountantReport.trialBalance) {
      return TrialBalancePage(
        onBack: _backToReports,
      );
    }

    return _buildReportsList();
  }

  Widget _buildReportsList() {
    return ReportGlassPageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportTitleActions(
            title: 'Accountant Reports',
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
                    'Accountant',
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
                  reportName: 'Account Transactions',
                  lastVisited: '-',
                  createdBy: 'System Generated',
                  onTap: () {
                    _handleUnavailable('Account Transactions');
                  },
                ),
                _ReportRow(
                  reportName: 'General Ledger',
                  lastVisited: '-',
                  createdBy: 'System Generated',
                  onTap: () {
                    _handleUnavailable('General Ledger');
                  },
                ),
                _ReportRow(
                  reportName: 'Journal Report',
                  lastVisited: '-',
                  createdBy: 'System Generated',
                  onTap: () {
                    _handleUnavailable('Journal Report');
                  },
                ),
                _ReportRow(
                  reportName: 'Trial Balance',
                  lastVisited: '24/01/2023 11:23 PM',
                  createdBy: 'System Generated',
                  showBottomBorder: false,
                  onTap: () {
                    setState(() {
                      selectedReport = _AccountantReport.trialBalance;
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
