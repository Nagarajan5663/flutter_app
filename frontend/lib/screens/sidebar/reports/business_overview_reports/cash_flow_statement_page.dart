import 'package:flutter/material.dart';
import 'widgets/report_glass_widgets.dart';

class CashFlowStatementPage extends StatelessWidget {
  final VoidCallback onBack;
  const CashFlowStatementPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return ReportGlassPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportTitleBar(title: 'Cash Flow Statement', onBack: onBack),
            const SizedBox(height: 18),
            const ReportNotice(
              text:
                  'Unable to Generate Report: A Cash Flow Statement requires tracking the actual movement of cash (e.g., bank transactions, loan payments, asset purchases). This data is not currently available in the database.\nThe structure below is a placeholder only.',
            ),
            const SizedBox(height: 18),
            const ReportSectionTable(
              rows: [
                ReportRowData('Cash Flow from Operating Activities', '', style: ReportRowStyle.section),
                ReportRowData('Cash received from customers', '0.00', indent: true),
                ReportRowData('Cash paid to suppliers/employees', '(0.00)', indent: true),
                ReportRowData('Other operating cash flow', '0.00', indent: true),
                ReportRowData('Net Cash from Operating Activities', '0.00', style: ReportRowStyle.subtotal),
                ReportRowData('Cash Flow from Investing Activities', '', style: ReportRowStyle.section),
                ReportRowData('Purchase of Fixed Assets', '(0.00)', indent: true),
                ReportRowData('Sale of Fixed Assets', '0.00', indent: true),
                ReportRowData('Net Cash from Investing Activities', '0.00', style: ReportRowStyle.subtotal),
                ReportRowData('Cash Flow from Financing Activities', '', style: ReportRowStyle.section),
                ReportRowData('Proceeds from Loans', '0.00', indent: true),
                ReportRowData('Repayment of Loans', '(0.00)', indent: true),
                ReportRowData('Equity contributions / (Withdrawals)', '0.00', indent: true),
                ReportRowData('Net Cash from Financing Activities', '0.00', style: ReportRowStyle.subtotal),
                ReportRowData('Net Increase/(Decrease) in Cash', '0.00', style: ReportRowStyle.total),
                ReportRowData('Cash at beginning of period', '0.00', indent: true),
                ReportRowData('Cash at end of period', '0.00', style: ReportRowStyle.subtotal),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
