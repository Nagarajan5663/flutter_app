import 'package:flutter/material.dart';

class InventoryAdjustmentsTab extends StatelessWidget {
  final bool isMobile;

  const InventoryAdjustmentsTab({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        // The table needs a minimum width on smaller screens.
        // IMPORTANT:
        // Never use double.infinity as the width of a child
        // inside a horizontal SingleChildScrollView.
        final double tableWidth = isMobile
            ? 850
            : constraints.maxWidth < 850
                ? 850
                : constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // ADJUSTMENT HISTORY
            // ======================================================

            const Text(
              'Adjustment History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),

            const SizedBox(height: 18),

            // ======================================================
            // TABLE
            // ======================================================

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD9DEE5),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        // ------------------------------------------------
                        // TABLE HEADER
                        // ------------------------------------------------

                        Container(
                          width: tableWidth,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 18,
                            vertical: 15,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF7F7F9),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _headerText('DATE'),
                              ),

                              Expanded(
                                flex: 2,
                                child: _headerText('ITEM'),
                              ),

                              Expanded(
                                flex: 2,
                                child: _headerText('SKU'),
                              ),

                              Expanded(
                                flex: 2,
                                child: _headerText('TYPE'),
                              ),

                              Expanded(
                                flex: 2,
                                child: _headerText('QUANTITY'),
                              ),

                              Expanded(
                                flex: 3,
                                child: _headerText('REASON'),
                              ),

                              Expanded(
                                flex: 2,
                                child: _headerText('STATUS'),
                              ),

                              Expanded(
                                flex: 2,
                                child: _headerText('ACTIONS'),
                              ),
                            ],
                          ),
                        ),

                        // ------------------------------------------------
                        // DIVIDER
                        // ------------------------------------------------

                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFD9DEE5),
                        ),

                        // ------------------------------------------------
                        // EMPTY STATE
                        // ------------------------------------------------

                        Container(
                          width: tableWidth,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 22,
                          ),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'No inventory adjustments found.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF42474D),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _headerText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isMobile ? 11 : 13,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF606060),
      ),
    );
  }
}