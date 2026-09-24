import 'package:flutter/material.dart';

import 'widgets/report_glass_widgets.dart';

class ArAgingSummaryPage extends StatelessWidget {
  final VoidCallback onBack;

  const ArAgingSummaryPage({
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
            title: 'AR Aging Summary',
            actions: ReportActionBar(onBack: onBack),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 0, 38, 38),
            child: ReportGlassCard(
              padding: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const minWidth = 980.0;
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
                                Expanded(flex: 4, child: ReportTableHeaderText('CUSTOMER NAME')),
                                Expanded(flex: 2, child: ReportTableHeaderText('TOTAL DUE')),
                                Expanded(flex: 2, child: ReportTableHeaderText('CURRENT')),
                                Expanded(flex: 2, child: ReportTableHeaderText('1-30 DAYS')),
                                Expanded(flex: 2, child: ReportTableHeaderText('31-60 DAYS')),
                                Expanded(flex: 2, child: ReportTableHeaderText('61-90 DAYS')),
                                Expanded(flex: 2, child: ReportTableHeaderText('> 90 DAYS')),
                              ],
                            ),
                          ),
                          const ReportEmptyRow(
                            message: 'No outstanding receivables found.',
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
