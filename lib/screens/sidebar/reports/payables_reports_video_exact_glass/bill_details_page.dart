import 'package:flutter/material.dart';
import 'widgets/report_glass_widgets.dart';

class BillDetailsPage extends StatelessWidget {
  final VoidCallback onBack;

  const BillDetailsPage({
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
            title: 'Bill Details',
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
            minWidth: 1300,
            emptyText: 'No bills found.',
            headers: [
              ReportTableHeader('VENDOR NAME', flex: 3),
              ReportTableHeader('BILL #', flex: 2),
              ReportTableHeader('VENDOR INV #', flex: 2),
              ReportTableHeader('BILL DATE', flex: 2),
              ReportTableHeader('DUE DATE', flex: 2),
              ReportTableHeader('STATUS', flex: 2),
              ReportTableHeader('TOTAL AMOUNT', flex: 2),
              ReportTableHeader('AMOUNT PAID', flex: 2),
              ReportTableHeader('AMOUNT DUE', flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
