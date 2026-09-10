import 'package:flutter/material.dart';
import 'dashboard_metric_card.dart';

class ProfitLossSection extends StatelessWidget {
  const ProfitLossSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ====================================================================
        // SECTION TITLE
        // ====================================================================

        const Row(
          children: [
            Icon(
              Icons.account_balance_outlined,
              color: Colors.white,
              size: 22,
            ),

            SizedBox(width: 8),

            Text(
              'Profit & Loss Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        const Divider(
          height: 1,
          thickness: 1,
          color: Colors.white38,
        ),

        const SizedBox(height: 20),

        // ====================================================================
        // CARDS
        // ====================================================================

        const DashboardMetricGrid(
          children: [
            // ----------------------------------------------------------------
            // INVESTMENTS RECEIVED - GREEN
            // ----------------------------------------------------------------

            DashboardMetricCard(
              title: 'Investments Received',
              value: '₹0.00',
              icon: Icons.savings_outlined,
              iconColor: Color(0xFF22C55E),
              iconBackground: Color(0xFFDCFCE7),
              valueColor: Color(0xFF22C55E),
            ),

            // ----------------------------------------------------------------
            // LOANS RECEIVED - BLUE
            // ----------------------------------------------------------------

            DashboardMetricCard(
              title: 'Loans Received',
              value: '₹0.00',
              icon: Icons.account_balance_wallet_outlined,
              iconColor: Color(0xFF3B82F6),
              iconBackground: Color(0xFFDBEAFE),
              valueColor: Color(0xFF3B82F6),
            ),

            // ----------------------------------------------------------------
            // LOANS REPAID - RED
            // ----------------------------------------------------------------

            DashboardMetricCard(
              title: 'Loans Repaid',
              value: '₹0.00',
              icon: Icons.payments_outlined,
              iconColor: Color(0xFFEF4444),
              iconBackground: Color(0xFFFEE2E2),
              valueColor: Color(0xFFEF4444),
            ),

            // ----------------------------------------------------------------
            // NET POSITION - PURPLE
            // ----------------------------------------------------------------

            DashboardMetricCard(
              title: 'Net Position',
              value: '₹0.00',
              icon: Icons.auto_graph_outlined,
              iconColor: Color(0xFF8B5CF6),
              iconBackground: Color(0xFFEDE9FE),
              valueColor: Color(0xFF8B5CF6),
            ),
          ],
        ),
      ],
    );
  }
}