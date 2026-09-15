import 'package:flutter/material.dart';

import 'glass_widgets.dart';

class CurrentStockTab extends StatelessWidget {
  final bool isMobile;

  const CurrentStockTab({
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
        const double minimumWidth = 650;

        final double tableWidth =
            constraints.maxWidth <
                    minimumWidth
                ? minimumWidth
                : constraints.maxWidth;

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ==================================================
            // TITLE
            // ==================================================

            Text(
              'Available Stock (Consumable Products)',
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

            // ==================================================
            // TABLE
            // ==================================================

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
                          horizontal: 22,
                          vertical: 18,
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
                              flex: 4,
                              child:
                                  InventoryTableHeader(
                                title:
                                    'ITEM NAME',
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child:
                                  InventoryTableHeader(
                                title: 'SKU',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  InventoryTableHeader(
                                title:
                                    'CURRENT STOCK',
                                textAlign:
                                    TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ------------------------------------------
                      // EMPTY
                      // ------------------------------------------

                      const InventoryEmptyState(
                        icon: Icons
                            .inventory_2_outlined,
                        title:
                            'No stock available',
                        message:
                            'No items are currently available in stock.',
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