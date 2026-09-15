import 'package:flutter/material.dart';

import 'widgets/report_glass_widgets.dart';

class AbcClassificationPage extends StatelessWidget {
  final VoidCallback onBack;

  const AbcClassificationPage({
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
            title: 'ABC Classification (Based on Sales Value)',
            actions: ReportActionBar(onBack: onBack),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 0, 38, 14),
            child: const ReportNoticeBanner(
              text:
                  'This ABC classification is based on the total sales value recorded in invoices (excluding Draft/Void). Class A items represent the top 80% of value, Class B the next 15%, and Class C the remaining value.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 0, 38, 38),
            child: ReportGlassCard(
              padding: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const minWidth = 1030.0;
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
                              horizontal: 20,
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
                                Expanded(
                                  flex: 3,
                                  child: ReportTableHeaderText('ITEM NAME'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ReportTableHeaderText('SKU'),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: ReportTableHeaderText('TOTAL SALES VALUE'),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: ReportTableHeaderText('% OF TOTAL VALUE'),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: ReportTableHeaderText('CUMULATIVE %'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ReportTableHeaderText(
                                    'ABC CLASS',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const ReportEmptyRow(
                            message: 'No sales data found for inventory items.',
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
