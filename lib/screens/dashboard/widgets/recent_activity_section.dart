import 'package:flutter/material.dart';

import 'dashboard_section_header.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DashboardSectionHeader(
          title: 'Recent Activity',
          icon: Icons.history,
        ),

        const SizedBox(height: 20),

        const _EmptyActivityCard(
          title: 'Recent Revenue',
          message: 'No recent revenue found.',
        ),

        const SizedBox(height: 16),

        const _EmptyActivityCard(
          title: 'Recent Expenses',
          message: 'No recent expenses found.',
        ),

        const SizedBox(height: 16),

        const _RecentInventoryCard(),
      ],
    );
  }
}

class _EmptyActivityCard extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyActivityCard({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 145,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE1E1E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF123A5C),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          const Divider(
            height: 1,
            color: Color(0xFFE6E6E6),
          ),

          Expanded(
            child: Center(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentInventoryCard extends StatelessWidget {
  const _RecentInventoryCard();

  @override
  Widget build(BuildContext context) {
    final items = [
      const _InventoryActivity(
        itemId: '#162',
        time: '20 Aug 2026, 08:38 AM',
      ),
      const _InventoryActivity(
        itemId: '#162',
        time: '20 Aug 2026, 08:38 AM',
      ),
      const _InventoryActivity(
        itemId: '#161',
        time: '20 Aug 2026, 08:37 AM',
      ),
      const _InventoryActivity(
        itemId: '#159',
        time: '20 Aug 2026, 08:37 AM',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE1E1E1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Inventory Adjustments',
            style: TextStyle(
              color: Color(0xFF123A5C),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          const Divider(
            height: 1,
            color: Color(0xFFE6E6E6),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 255,
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 1,
                    color: Color(0xFFEEEEEE),
                  );
                },
                itemBuilder: (context, index) {
                  return items[index];
                },
              ),
            ),
          ),

          const Divider(
            color: Color(0xFFE6E6E6),
          ),

          const Center(
            child: Text(
              'Note: Inventory data is system-wide '
              '(not filtered by organization) due to current database schema.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryActivity extends StatelessWidget {
  final String itemId;
  final String time;

  const _InventoryActivity({
    required this.itemId,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFFF1E9FC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              size: 16,
              color: Color(0xFF8B5AD9),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item ID $itemId adjusted (increase)',
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const Text(
            '+1 Units',
            style: TextStyle(
              color: Color(0xFF7D45D6),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}