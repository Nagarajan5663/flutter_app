import 'package:flutter/material.dart';

import 'widgets/report_glass_widgets.dart';

class InventorySummaryPage extends StatelessWidget {
  final VoidCallback onBack;

  const InventorySummaryPage({
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
            title: 'Inventory Summary',
            actions: ReportActionBar(onBack: onBack),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 0, 38, 38),
            child: ReportGlassCard(
              padding: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const minWidth = 760.0;
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
                                  flex: 4,
                                  child: ReportTableHeaderText('ITEM NAME'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ReportTableHeaderText('SKU'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ReportTableHeaderText('UNIT'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ReportTableHeaderText(
                                    'CURRENT STOCK',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const ReportEmptyRow(
                            message: 'No inventory items found.',
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
