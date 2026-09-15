import 'package:flutter/material.dart';
import 'widgets/report_glass_widgets.dart';

class ExpensesByCategoryPage extends StatelessWidget {
  final VoidCallback onBack;

  const ExpensesByCategoryPage({
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
            title: 'Expenses by Category',
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
            minWidth: 800,
            emptyText: 'No expenses found for any category.',
            headers: [
              ReportTableHeader('CATEGORY', flex: 4),
              ReportTableHeader('EXPENSE COUNT', flex: 3),
              ReportTableHeader('TOTAL AMOUNT', flex: 3),
            ],
          ),
        ],
      ),
    );
  }
}
