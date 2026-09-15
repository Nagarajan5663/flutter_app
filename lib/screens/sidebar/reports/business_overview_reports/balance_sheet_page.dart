import 'package:flutter/material.dart';
import 'widgets/report_glass_widgets.dart';

class BalanceSheetPage extends StatelessWidget {
  final VoidCallback onBack;
  const BalanceSheetPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return _BalanceSheetBody(title: 'Balance Sheet', onBack: onBack);
  }
}

class HorizontalBalanceSheetPage extends StatelessWidget {
  final VoidCallback onBack;
  const HorizontalBalanceSheetPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return _BalanceSheetBody(title: 'Horizontal Balance Sheet', onBack: onBack);
  }
}

class _BalanceSheetBody extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const _BalanceSheetBody({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return ReportGlassPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportTitleBar(title: title, onBack: onBack),
            const SizedBox(height: 18),
            const ReportNotice(
              text:
                  'Unable to Generate Report: A Balance Sheet requires a full chart of accounts and general ledger data (Assets, Liabilities, Equity), which is not currently tracked in the database.\nThe structure below is a placeholder only.',
            ),
            const SizedBox(height: 18),
            const ReportSectionTable(
              rows: [
                ReportRowData('ASSETS', '', style: ReportRowStyle.section),
                ReportRowData('Current Assets', '', style: ReportRowStyle.subtotal),
                ReportRowData('Cash and Cash Equivalents', '0.00', indent: true),
                ReportRowData('Accounts Receivable', '0.00', indent: true),
                ReportRowData('Inventory', '0.00', indent: true),
                ReportRowData('Total Current Assets', '0.00', style: ReportRowStyle.subtotal),
                ReportRowData('Non-Current Assets', '', style: ReportRowStyle.subtotal),
                ReportRowData('Property, Plant, and Equipment', '0.00', indent: true),
                ReportRowData('Intangible Assets', '0.00', indent: true),
                ReportRowData('Total Non-Current Assets', '0.00', style: ReportRowStyle.subtotal),
                ReportRowData('TOTAL ASSETS', '0.00', style: ReportRowStyle.total),
                ReportRowData('LIABILITIES AND EQUITY', '', style: ReportRowStyle.section),
                ReportRowData('Liabilities', '', style: ReportRowStyle.subtotal),
                ReportRowData('Accounts Payable', '0.00', indent: true),
                ReportRowData('Short-term Loans', '0.00', indent: true),
                ReportRowData('Total Current Liabilities', '0.00', style: ReportRowStyle.subtotal),
                ReportRowData('Long-term Loans', '0.00', indent: true),
                ReportRowData('Total Liabilities', '0.00', style: ReportRowStyle.subtotal),
                ReportRowData('Equity', '', style: ReportRowStyle.subtotal),
                ReportRowData("Owner's Capital / Share Capital", '0.00', indent: true),
                ReportRowData('Retained Earnings', '0.00', indent: true),
                ReportRowData('Total Equity', '0.00', style: ReportRowStyle.subtotal),
                ReportRowData('TOTAL LIABILITIES AND EQUITY', '0.00', style: ReportRowStyle.total),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
