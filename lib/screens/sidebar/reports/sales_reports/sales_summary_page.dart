import 'package:flutter/material.dart';

import 'widgets/report_glass_widgets.dart';

class SalesSummaryPage extends StatelessWidget {
  final VoidCallback onBack;

  const SalesSummaryPage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 760;

    return ReportGlassPageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportPageHeader(
            title: 'Sales Summary',
            actions: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ReportGlassButton(
                  label: 'Back to Sales Reports',
                  icon: Icons.arrow_back_rounded,
                  primary: false,
                  onPressed: onBack,
                ),
                const ReportGlassButton(
                  label: 'Download PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  onPressed: null,
                ),
                const ReportGlassButton(
                  label: 'Download Excel (CSV)',
                  icon: Icons.table_view_outlined,
                  onPressed: null,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 18 : 38,
              0,
              isMobile ? 18 : 38,
              isMobile ? 20 : 38,
            ),
            child: ReportGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: const Column(
                children: [
                  _SummaryRow('Total Invoices (Excl. Draft/Void):', '0'),
                  _SummaryDivider(),
                  _SummaryRow('Total Sales Amount:', '₹ 0.00'),
                  _SummaryDivider(),
                  _SummaryRow('Total Amount Received:', '₹ 0.00'),
                  _SummaryDivider(),
                  _SummaryRow('Total Amount Due:', '₹ 0.00'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF314758),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: ReportGlassTheme.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Colors.white.withValues(alpha: 0.70),
    );
  }
}
