import 'package:flutter/material.dart';

class CurrentStockTab extends StatelessWidget {
  final bool isMobile;

  const CurrentStockTab({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --------------------------------------------------
        // SECTION TITLE
        // --------------------------------------------------
        Text(
          'Available Stock (Consumable Products)',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
          ),
        ),

        const SizedBox(height: 18),

        // --------------------------------------------------
        // TABLE
        // --------------------------------------------------
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFD9DEE5),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              // TABLE HEADER
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 18,
                  vertical: 15,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'ITEM NAME',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF606060),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 3,
                      child: Text(
                        'SKU',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF606060),
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 2,
                      child: Text(
                        'CURRENT STOCK',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF606060),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              // DIVIDER
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFD9DEE5),
              ),

              // EMPTY STATE
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 18,
                  vertical: 22,
                ),
                child: const Text(
                  'No items currently in stock.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF42474D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}