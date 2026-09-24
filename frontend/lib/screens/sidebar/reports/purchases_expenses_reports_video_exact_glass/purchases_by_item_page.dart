import 'package:flutter/material.dart';
import 'widgets/report_glass_widgets.dart';

class PurchasesByItemPage extends StatelessWidget {
  final VoidCallback onBack;

  const PurchasesByItemPage({
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
            title: 'Purchases by Item',
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
            minWidth: 900,
            emptyText: 'No purchased items found in bills.',
            headers: [
              ReportTableHeader('ITEM NAME', flex: 3),
              ReportTableHeader('SKU', flex: 2),
              ReportTableHeader('QUANTITY PURCHASED', flex: 2),
              ReportTableHeader('AVG. RATE', flex: 2),
              ReportTableHeader('TOTAL AMOUNT', flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
