import 'package:flutter/material.dart';
import 'widgets/report_glass_widgets.dart';

class ApAgingSummaryPage extends StatelessWidget {
  final VoidCallback onBack;

  const ApAgingSummaryPage({
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
            title: 'AP Aging Summary',
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
            minWidth: 1050,
            emptyText: 'No outstanding payables found.',
            headers: [
              ReportTableHeader('VENDOR NAME', flex: 3),
              ReportTableHeader('TOTAL DUE', flex: 2),
              ReportTableHeader('CURRENT', flex: 2),
              ReportTableHeader('1-30 DAYS', flex: 2),
              ReportTableHeader('31-60 DAYS', flex: 2),
              ReportTableHeader('61-90 DAYS', flex: 2),
              ReportTableHeader('> 90 DAYS', flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
