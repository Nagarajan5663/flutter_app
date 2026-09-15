import 'package:flutter/material.dart';

import 'abc_classification_page.dart';
import 'inventory_aging_summary_page.dart';
import 'inventory_summary_page.dart';
import 'inventory_valuation_summary_page.dart';
import 'widgets/report_glass_widgets.dart';

class InventoryReportsPage extends StatefulWidget {
  final VoidCallback? onBackToAllReports;

  const InventoryReportsPage({
    super.key,
    this.onBackToAllReports,
  });

  @override
  State<InventoryReportsPage> createState() => _InventoryReportsPageState();
}

class _InventoryReportsPageState extends State<InventoryReportsPage> {
  String? _activeReport;

  void _backToInventoryReports() {
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
      case 'Inventory Summary':
        return InventorySummaryPage(onBack: _backToInventoryReports);
      case 'Inventory Valuation Summary':
        return InventoryValuationSummaryPage(onBack: _backToInventoryReports);
      case 'Inventory Aging Summary':
        return InventoryAgingSummaryPage(onBack: _backToInventoryReports);
      case 'ABC Classification':
        return AbcClassificationPage(onBack: _backToInventoryReports);
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
            title: 'Inventory Reports',
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
                      'Inventory',
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
                          flex: 2,
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
                  _reportRow('Inventory Summary'),
                  _reportRow('Inventory Valuation Summary'),
                  _reportRow('Inventory Aging Summary'),
                  _reportRow('ABC Classification'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportRow(String title) {
    return _HoverReportRow(
      title: title,
      onTap: () => setState(() => _activeReport = title),
    );
  }
}

class _HoverReportRow extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _HoverReportRow({
    required this.title,
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
              const Expanded(
                flex: 2,
                child: Text(
                  '-',
                  style: TextStyle(
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
