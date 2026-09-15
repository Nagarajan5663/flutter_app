import 'package:flutter/material.dart';

import 'widgets/report_glass_widgets.dart';

class InvoiceDetailsPage extends StatelessWidget {
  final VoidCallback onBack;

  const InvoiceDetailsPage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ReportGlassPageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportPageHeader(
            title: 'Invoice Details',
            actions: ReportActionBar(onBack: onBack),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 0, 38, 38),
            child: ReportGlassCard(
              padding: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const minWidth = 1120.0;
                  final width = constraints.maxWidth < minWidth
                      ? minWidth
                      : constraints.maxWidth;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.70),
                                ),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 3, child: ReportTableHeaderText('CUSTOMER NAME')),
                                Expanded(flex: 2, child: ReportTableHeaderText('INVOICE #')),
                                Expanded(flex: 2, child: ReportTableHeaderText('INVOICE DATE')),
                                Expanded(flex: 2, child: ReportTableHeaderText('DUE DATE')),
                                Expanded(flex: 2, child: ReportTableHeaderText('STATUS')),
                                Expanded(flex: 2, child: ReportTableHeaderText('TOTAL AMOUNT')),
                                Expanded(flex: 2, child: ReportTableHeaderText('AMOUNT PAID')),
                                Expanded(flex: 2, child: ReportTableHeaderText('AMOUNT DUE')),
                              ],
                            ),
                          ),
                          const ReportEmptyRow(
                            message: 'No invoices found.',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
