import 'package:flutter/material.dart';
import 'widgets/report_glass_widgets.dart';

class PurchasesByVendorPage extends StatelessWidget {
  final VoidCallback onBack;

  const PurchasesByVendorPage({
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
            title: 'Purchases by Vendor',
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
            emptyText: 'No purchases found for any vendor.',
            headers: [
              ReportTableHeader('VENDOR NAME', flex: 3),
              ReportTableHeader('BILL COUNT', flex: 2),
              ReportTableHeader('TOTAL BILLED', flex: 2),
              ReportTableHeader('TOTAL PAID', flex: 2),
              ReportTableHeader('BALANCE DUE', flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
