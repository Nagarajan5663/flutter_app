import 'package:flutter/material.dart';

class ItemsTab extends StatelessWidget {
  final VoidCallback onAddItem;

  const ItemsTab({
    super.key,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    const double minimumTableWidth = 900;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4E9EF),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final double tableWidth =
                constraints.maxWidth <
                        minimumTableWidth
                    ? minimumTableWidth
                    : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // TABLE HEADER
                    // ==================================================

                    Container(
                      width: tableWidth,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 17,
                      ),
                      decoration:
                          const BoxDecoration(
                        color: Color(0xFFF7F9FB),
                        border: Border(
                          bottom: BorderSide(
                            color:
                                Color(0xFFE4E9EF),
                          ),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _TableHeading(
                              title: 'NAME',
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: _TableHeading(
                              title: 'SKU',
                            ),
                          ),

                          Expanded(
                            flex: 3,
                            child: _TableHeading(
                              title:
                                  'PURCHASE PRICE',
                            ),
                          ),

                          Expanded(
                            flex: 3,
                            child: _TableHeading(
                              title:
                                  'SALES PRICE',
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: _TableHeading(
                              title: 'ACTIONS',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // EMPTY STATE
                    // ==================================================

                    SizedBox(
                      width: tableWidth,
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 58,
                        ),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                      0xFFEEF5FA,
                                    ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  22,
                                ),
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .inventory_2_outlined,
                                size: 36,
                                color:
                                    Color(
                                  0xFF487EA6,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            const Text(
                              'No items yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.w700,
                                color:
                                    Color(
                                  0xFF25394B,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            const Text(
                              'Add your first inventory item to start managing products.',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color:
                                    Color(
                                  0xFF85919D,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 21,
                            ),

                            OutlinedButton.icon(
                              onPressed:
                                  onAddItem,
                              icon:
                                  const Icon(
                                Icons.add,
                                size: 18,
                              ),
                              label:
                                  const Text(
                                'Add First Item',
                              ),
                              style:
                                  OutlinedButton
                                      .styleFrom(
                                foregroundColor:
                                    const Color(
                                  0xFF1D527A,
                                ),
                                side:
                                    const BorderSide(
                                  color:
                                      Color(
                                    0xFFB8CBD9,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 18,
                                  vertical: 13,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// TABLE HEADING
// ============================================================

class _TableHeading extends StatelessWidget {
  final String title;

  const _TableHeading({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        letterSpacing: 0.7,
        fontWeight: FontWeight.w700,
        color: Color(0xFF657687),
      ),
    );
  }
}