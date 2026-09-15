import 'package:flutter/material.dart';

import 'glass_widgets.dart';

class ReturnableAssetsTab
    extends StatefulWidget {
  final bool isMobile;

  const ReturnableAssetsTab({
    super.key,
    required this.isMobile,
  });

  @override
  State<ReturnableAssetsTab>
      createState() =>
          _ReturnableAssetsTabState();
}

class _ReturnableAssetsTabState
    extends State<ReturnableAssetsTab> {
  int selectedSubTab = 0;

  @override
  Widget build(BuildContext context) {
    final bool isMobile =
        widget.isMobile;

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        const double minimumWidth = 900;

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
            // SUB TABS
            // ==================================================

            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.31,
                ),
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: 0.70,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                child: Row(
                  children: [
                    _buildSubTab(
                      title:
                          'Available Assets',
                      icon: Icons
                          .inventory_2_outlined,
                      index: 0,
                    ),
                    _buildSubTab(
                      title: 'In Field',
                      icon:
                          Icons.location_on_outlined,
                      index: 1,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // TITLE
            // ==================================================

            Text(
              selectedSubTab == 0
                  ? 'Available Returnable Assets'
                  : 'Returnable Assets In Field',
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
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 20,
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
                              flex: 2,
                              child:
                                  InventoryTableHeader(
                                title:
                                    'ASSET TAG',
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child:
                                  InventoryTableHeader(
                                title:
                                    'ITEM NAME',
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
                              flex: 3,
                              child:
                                  InventoryTableHeader(
                                title:
                                    'SERIAL NUMBER',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child:
                                  InventoryTableHeader(
                                title:
                                    'ACTIONS',
                              ),
                            ),
                          ],
                        ),
                      ),

                      InventoryEmptyState(
                        icon: selectedSubTab ==
                                0
                            ? Icons
                                .inventory_2_outlined
                            : Icons
                                .location_on_outlined,
                        title: selectedSubTab ==
                                0
                            ? 'No available assets'
                            : 'No assets in field',
                        message:
                            selectedSubTab ==
                                    0
                                ? 'No returnable assets are currently available.'
                                : 'No returnable assets are currently in the field.',
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

  // ============================================================
  // SUB TAB
  // ============================================================

  Widget _buildSubTab({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final bool selected =
        selectedSubTab == index;

    return InventoryHoverScale(
      scale: 1.015,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(10),
          onTap: () {
            setState(() {
              selectedSubTab = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 220,
            ),
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(
                      alpha: 0.82,
                    )
                  : Colors.transparent,
              borderRadius:
                  BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(
                          0xFF123456,
                        ).withValues(
                          alpha: 0.07,
                        ),
                        blurRadius: 12,
                        offset:
                            const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: selected
                      ? const Color(
                          0xFF153F5F,
                        )
                      : const Color(
                          0xFF80909D,
                        ),
                ),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected
                        ? const Color(
                            0xFF153F5F,
                          )
                        : const Color(
                            0xFF748693,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}