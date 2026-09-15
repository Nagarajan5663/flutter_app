import 'package:flutter/material.dart';

import 'balance_sheet_page.dart';
import 'cash_flow_statement_page.dart';
import 'profit_loss_page.dart';
import 'widgets/report_glass_widgets.dart';

enum BusinessOverviewReport {
  overview,
  profitLoss,
  profitLossScheduleIII,
  horizontalProfitLoss,
  cashFlowStatement,
  balanceSheet,
  horizontalBalanceSheet,
}

class BusinessOverviewPage extends StatefulWidget {
  final VoidCallback? onBackToAllReports;

  const BusinessOverviewPage({
    super.key,
    this.onBackToAllReports,
  });

  @override
  State<BusinessOverviewPage> createState() => _BusinessOverviewPageState();
}

class _BusinessOverviewPageState extends State<BusinessOverviewPage> {
  BusinessOverviewReport selected = BusinessOverviewReport.overview;

  void _open(BusinessOverviewReport report) {
    setState(() => selected = report);
  }

  void _backToOverview() {
    setState(() => selected = BusinessOverviewReport.overview);
  }

  @override
  Widget build(BuildContext context) {
    switch (selected) {
      case BusinessOverviewReport.profitLoss:
        return ProfitLossPage(onBack: _backToOverview);
      case BusinessOverviewReport.profitLossScheduleIII:
        return ProfitLossScheduleIIIPage(onBack: _backToOverview);
      case BusinessOverviewReport.horizontalProfitLoss:
        return HorizontalProfitLossPage(onBack: _backToOverview);
      case BusinessOverviewReport.cashFlowStatement:
        return CashFlowStatementPage(onBack: _backToOverview);
      case BusinessOverviewReport.balanceSheet:
        return BalanceSheetPage(onBack: _backToOverview);
      case BusinessOverviewReport.horizontalBalanceSheet:
        return HorizontalBalanceSheetPage(onBack: _backToOverview);
      case BusinessOverviewReport.overview:
        return _buildOverview(context);
    }
  }

  Widget _buildOverview(BuildContext context) {
    return ReportGlassPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final button = ElevatedButton.icon(
                  onPressed: widget.onBackToAllReports ??
                      () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.chevron_left_rounded, size: 18),
                  label: const Text('Back to All Reports'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B8A8D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                if (constraints.maxWidth < 650) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Business Overview',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: reportNavy,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(alignment: Alignment.centerRight, child: button),
                    ],
                  );
                }
                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Business Overview',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: reportNavy,
                        ),
                      ),
                    ),
                    button,
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            ReportGlassCard(
              enableTilt: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 17, 16, 15),
                    child: Text(
                      'Business Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: reportNavy,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  const _OverviewHeader(),
                  _OverviewRow(
                    name: 'Profit and Loss',
                    lastVisited: '04/05/2025 07:49 PM',
                    onTap: () => _open(BusinessOverviewReport.profitLoss),
                  ),
                  _OverviewRow(
                    name: 'Profit and Loss (Schedule III)',
                    lastVisited: '-',
                    onTap: () => _open(BusinessOverviewReport.profitLossScheduleIII),
                  ),
                  _OverviewRow(
                    name: 'Horizontal Profit and Loss',
                    lastVisited: '-',
                    onTap: () => _open(BusinessOverviewReport.horizontalProfitLoss),
                  ),
                  _OverviewRow(
                    name: 'Cash Flow Statement',
                    lastVisited: '24/03/2023 11:37 PM',
                    onTap: () => _open(BusinessOverviewReport.cashFlowStatement),
                  ),
                  _OverviewRow(
                    name: 'Balance Sheet',
                    lastVisited: '14/07/2025 02:31 PM',
                    onTap: () => _open(BusinessOverviewReport.balanceSheet),
                  ),
                  _OverviewRow(
                    name: 'Horizontal Balance Sheet',
                    lastVisited: '-',
                    onTap: () => _open(BusinessOverviewReport.horizontalBalanceSheet),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      color: Colors.white.withValues(alpha: 0.24),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'REPORT NAME',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF657687),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'LAST VISITED',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF657687),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'CREATED BY',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF657687),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatefulWidget {
  final String name;
  final String lastVisited;
  final VoidCallback onTap;

  const _OverviewRow({
    required this.name,
    required this.lastVisited,
    required this.onTap,
  });

  @override
  State<_OverviewRow> createState() => _OverviewRowState();
}

class _OverviewRowState extends State<_OverviewRow> {
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: hovering
                ? Colors.white.withValues(alpha: 0.44)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.70),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  widget.name,
                  style: const TextStyle(
                    color: Color(0xFF2296CF),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  widget.lastVisited,
                  style: const TextStyle(
                    color: Color(0xFF344755),
                    fontSize: 13,
                  ),
                ),
              ),
              const Expanded(
                flex: 3,
                child: Text(
                  'System Generated',
                  style: TextStyle(
                    color: Color(0xFF344755),
                    fontSize: 13,
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
