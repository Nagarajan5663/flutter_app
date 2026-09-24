import 'package:flutter/material.dart';
import 'widgets/report_glass_widgets.dart';

class VendorBalanceSummaryPage extends StatelessWidget {
  final VoidCallback onBack;

  const VendorBalanceSummaryPage({
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
            title: 'Vendor Balance Summary',
            actions: [
              ReportGlassButton(
                label: 'Back to Payables Reports',
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
          const PayablesReportTable(
            minWidth: 900,
            emptyText: 'No vendors with billing activity found.',
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
