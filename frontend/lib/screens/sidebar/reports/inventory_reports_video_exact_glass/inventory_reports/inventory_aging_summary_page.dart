import 'package:flutter/material.dart';

import 'widgets/report_glass_widgets.dart';

class InventoryAgingSummaryPage extends StatelessWidget {
  final VoidCallback onBack;

  const InventoryAgingSummaryPage({
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
            title: 'Inventory Aging Summary',
            actions: ReportActionBar(onBack: onBack),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 0, 38, 14),
            child: const ReportNoticeBanner(
              text:
                  "Accurate inventory aging requires tracking stock receipt dates. The aging columns below (0-30 Days, etc.) currently show placeholders ('N/A') as this data is not available in the current database structure. The 'Current Stock' column reflects the total quantity on hand.",
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 0, 38, 38),
            child: ReportGlassCard(
              padding: EdgeInsets.zero,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const minWidth = 1050.0;
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
                                  flex: 2,
                                  child: ReportTableHeaderText('CURRENT STOCK'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ReportTableHeaderText('0–30 DAYS'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ReportTableHeaderText('31–60 DAYS'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ReportTableHeaderText('61–90 DAYS'),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ReportTableHeaderText(
                                    '> 90 DAYS',
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const ReportEmptyRow(
                            message: 'No inventory items found.',
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.70),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Total Stock',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: ReportGlassTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(flex: 2, child: SizedBox()),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '0.00',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: ReportGlassTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'N/A',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: ReportGlassTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'N/A',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: ReportGlassTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'N/A',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: ReportGlassTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'N/A',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: ReportGlassTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
