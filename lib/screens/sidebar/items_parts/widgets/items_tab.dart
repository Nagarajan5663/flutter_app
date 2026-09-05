import 'package:flutter/material.dart';

class ItemsTab extends StatelessWidget {
  final VoidCallback onAddItem;

  const ItemsTab({
    super.key,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          color: const Color(0xFFF7F8FA),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'NAME',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B5B5B),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'SKU',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B5B5B),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'PURCHASE PRICE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B5B5B),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'SALES PRICE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B5B5B),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'ACTIONS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B5B5B),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(
          height: 1,
          color: Color(0xFFD9DEE5),
        ),

        // Empty state
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
          child: const Text(
            'No items found.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF42474D),
            ),
          ),
        ),

        const Divider(
          height: 1,
          color: Color(0xFFD9DEE5),
        ),
      ],
    );
  }
}