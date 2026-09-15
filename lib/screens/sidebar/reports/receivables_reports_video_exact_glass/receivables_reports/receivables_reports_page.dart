import 'package:flutter/material.dart';

import 'ar_aging_details_page.dart';
import 'ar_aging_summary_page.dart';
import 'customer_balance_summary_page.dart';
import 'invoice_details_page.dart';
import 'widgets/report_glass_widgets.dart';

class ReceivablesReportsPage extends StatefulWidget {
  final VoidCallback? onBackToAllReports;

  const ReceivablesReportsPage({
    super.key,
    this.onBackToAllReports,
  });

  @override
  State<ReceivablesReportsPage> createState() => _ReceivablesReportsPageState();
}

class _ReceivablesReportsPageState extends State<ReceivablesReportsPage> {
  String? _activeReport;

  void _backToReceivablesReports() {
    setState(() => _activeReport = null);
  }

  void _backToAllReports() {
    if (widget.onBackToAllReports != null) {
      widget.onBackToAllReports!();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_activeReport) {
      case 'AR Aging Summary':
        return ArAgingSummaryPage(onBack: _backToReceivablesReports);
      case 'AR Aging Details':
        return ArAgingDetailsPage(onBack: _backToReceivablesReports);
      case 'Invoice Details':
        return InvoiceDetailsPage(onBack: _backToReceivablesReports);
      case 'Customer Balance Summary':
        return CustomerBalanceSummaryPage(onBack: _backToReceivablesReports);
      default:
        return _buildReportsList();
    }
  }

  Widget _buildReportsList() {
    return ReportGlassPageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportPageHeader(
            title: 'Receivables Reports',
            actions: ReportGlassButton(
              label: 'Back to All Reports',
              icon: Icons.chevron_left_rounded,
              onPressed: _backToAllReports,
              backgroundColor: const Color(0xFF7D8B8C),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 0, 38, 38),
            child: ReportGlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Text(
                      'Receivables',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ReportGlassTheme.navy,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: ReportTableHeaderText('REPORT NAME'),
                        ),
                        Expanded(
                          flex: 3,
                          child: ReportTableHeaderText('LAST VISITED'),
                        ),
                        Expanded(
                          flex: 3,
                          child: ReportTableHeaderText('CREATED BY'),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                  _reportRow('AR Aging Summary', '11/08/2025 05:48 PM'),
                  _reportRow('AR Aging Details', '10/10/2025 06:36 PM'),
                  _reportRow('Invoice Details', '10/10/2025 04:49 PM'),
                  _reportRow('Customer Balance Summary', '-'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportRow(String title, String lastVisited) {
    return _HoverReportRow(
      title: title,
      lastVisited: lastVisited,
      onTap: () => setState(() => _activeReport = title),
    );
  }
}

class _HoverReportRow extends StatefulWidget {
  final String title;
  final String lastVisited;
  final VoidCallback onTap;

  const _HoverReportRow({
    required this.title,
    required this.lastVisited,
    required this.onTap,
  });

  @override
  State<_HoverReportRow> createState() => _HoverReportRowState();
}

class _HoverReportRowState extends State<_HoverReportRow> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: hovering
                ? Colors.white.withValues(alpha: 0.26)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.58),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Color(0xFF2490C5),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  widget.lastVisited,
                  style: const TextStyle(
                    color: ReportGlassTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const Expanded(
                flex: 3,
                child: Text(
                  'System Generated',
                  style: TextStyle(
                    color: ReportGlassTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
