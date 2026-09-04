import 'package:flutter/material.dart';

import 'dashboard_metric_card.dart';
import 'dashboard_section_header.dart';

class ProfitLossSection extends StatelessWidget {
  const ProfitLossSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DashboardSectionHeader(
          title: 'Profit & Loss Overview',
          icon: Icons.request_quote_outlined,
        ),

        const SizedBox(height: 20),

        DashboardMetricGrid(
          children: const [
            DashboardMetricCard(
              title: 'Investments Received',
              value: '₹0',
              icon: Icons.savings_outlined,
              iconColor: Color(0xFF21B44B),
              iconBackground: Color(0xFFE9F8EC),
              valueColor: Color(0xFF21B44B),
            ),

            DashboardMetricCard(
              title: 'Loans Received',
              value: '₹0',
              icon: Icons.account_balance,
              iconColor: Color(0xFF21B44B),
              iconBackground: Color(0xFFE9F8EC),
              valueColor: Color(0xFF21B44B),
            ),

            DashboardMetricCard(
              title: 'Loans Repaid',
              value: '₹0',
              icon: Icons.payments_outlined,
              iconColor: Color(0xFFE63E50),
              iconBackground: Color(0xFFFCEAEC),
              valueColor: Color(0xFFE63E50),
            ),

            DashboardMetricCard(
              title: 'Net Position',
              value: '₹0',
              icon: Icons.balance,
              iconColor: Color(0xFF16ADBB),
              iconBackground: Color(0xFFE7F7F8),
              valueColor: Color(0xFF16ADBB),
            ),
          ],
        ),
      ],
    );
  }
}