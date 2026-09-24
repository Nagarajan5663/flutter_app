import 'package:flutter/material.dart';
import 'widgets/report_glass_widgets.dart';

class ExpenseDetailsPage extends StatelessWidget {
  final VoidCallback onBack;

  const ExpenseDetailsPage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ReportGlassPageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportTitleActions(
            title: 'Expense Details',
            actions: [
              ReportGlassButton(
                label: 'Back to Purchases Reports',
                icon: Icons.chevron_left_rounded,
                type: ReportGlassButtonType.back,
                onPressed: onBack,
              ),
              ReportGlassButton(
                label: 'Download PDF',
                icon: Icons.picture_as_pdf_outlined,
                type: ReportGlassButtonType.pdf,
                onPressed: () {},
              ),
              ReportGlassButton(
                label: 'Download Excel (CSV)',
                icon: Icons.table_view_outlined,
                type: ReportGlassButtonType.excel,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          const PurchasesExpensesReportTable(
            minWidth: 1050,
            emptyText: 'No expenses found.',
            headers: [
              ReportTableHeader('DATE', flex: 2),
              ReportTableHeader('EXPENSE #', flex: 2),
              ReportTableHeader('TYPE', flex: 2),
              ReportTableHeader('CATEGORY', flex: 2),
              ReportTableHeader('VENDOR', flex: 3),
              ReportTableHeader('STATUS', flex: 2),
              ReportTableHeader('AMOUNT', flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
