import 'package:flutter/material.dart';

import 'glass_widgets.dart';

class InventoryAdjustmentsTab
    extends StatelessWidget {
  final bool isMobile;

  const InventoryAdjustmentsTab({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        const double minimumWidth = 820;

        final double tableWidth =
            constraints.maxWidth <
                    minimumWidth
                ? minimumWidth
                : constraints.maxWidth;

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Adjustment History',
              style: TextStyle(
                fontSize:
                    isMobile ? 18 : 20,
                fontWeight:
                    FontWeight.w700,
                color:
                    const Color(0xFF203A4D),
              ),
            ),

            const SizedBox(height: 18),

            InventoryGlassTable(
              child:
                  SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // ------------------------------------------
                      // HEADER
                      // ------------------------------------------

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 15,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withValues(
                            alpha: 0.34,
                          ),
                          border: Border(
                            bottom:
                                BorderSide(
                              color: Colors
                                  .white
                                  .withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child:
                                  InventoryTableHeader(
                                title: 'DATE',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  InventoryTableHeader(
                                title: 'ITEM',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  InventoryTableHeader(
                                title: 'SKU',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  InventoryTableHeader(
                                title: 'TYPE',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  InventoryTableHeader(
                                title:
                                    'QUANTITY',
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child:
                                  InventoryTableHeader(
                                title:
                                    'REASON',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  InventoryTableHeader(
                                title:
                                    'STATUS',
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child:
                                  InventoryTableHeader(
                                title:
                                    'ACTIONS',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const InventoryEmptyState(
                        icon:
                            Icons.tune_rounded,
                        title:
                            'No adjustments yet',
                        message:
                            'Inventory adjustment history will appear here.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}