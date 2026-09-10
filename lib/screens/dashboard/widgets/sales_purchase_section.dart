import 'package:flutter/material.dart';
import 'dashboard_metric_card.dart';

class SalesPurchaseSection extends StatelessWidget {
  const SalesPurchaseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.point_of_sale_outlined,
              color: Colors.white,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Sales, Purchase & Customers',
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

        const DashboardMetricGrid(
          children: [
            DashboardMetricCard(
              title: 'Current Outstanding',
              value: '₹0.00',
              icon: Icons.schedule_outlined,
              iconColor: Color(0xFFF59E0B),
              iconBackground: Color(0xFFFEF3C7),
              valueColor: Color(0xFFF59E0B),
            ),
            DashboardMetricCard(
              title: 'Overdue Outstanding',
              value: '₹0.00',
              icon: Icons.warning_amber_rounded,
              iconColor: Color(0xFFEF4444),
              iconBackground: Color(0xFFFEE2E2),
              valueColor: Color(0xFFEF4444),
            ),
            DashboardMetricCard(
              title: 'New Customers',
              value: '0',
              icon: Icons.person_add_alt_1_outlined,
              iconColor: Color(0xFF3B82F6),
              iconBackground: Color(0xFFDBEAFE),
              valueColor: Color(0xFF3B82F6),
            ),
            DashboardMetricCard(
              title: 'Current Payables',
              value: '₹0.00',
              icon: Icons.receipt_long_outlined,
              iconColor: Color(0xFF8B5CF6),
              iconBackground: Color(0xFFEDE9FE),
              valueColor: Color(0xFF8B5CF6),
            ),
            DashboardMetricCard(
              title: 'Overdue Payables',
              value: '₹0.00',
              icon: Icons.error_outline_rounded,
              iconColor: Color(0xFFEF4444),
              iconBackground: Color(0xFFFEE2E2),
              valueColor: Color(0xFFEF4444),
            ),
          ],
        ),

        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 800) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DashboardHoverPanel(
                      accentColor: const Color(0xFF3B82F6),
                      child: const SizedBox(
                        height: 230,
                        child: _OutstandingContent(
                          title: 'Sales Outstanding',
                          icon: Icons.trending_up,
                          iconColor: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: DashboardHoverPanel(
                      accentColor: const Color(0xFF8B5CF6),
                      child: const SizedBox(
                        height: 230,
                        child: _OutstandingContent(
                          title: 'Purchase Outstanding',
                          icon: Icons.shopping_cart_outlined,
                          iconColor: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                DashboardHoverPanel(
                  accentColor: const Color(0xFF3B82F6),
                  child: const SizedBox(
                    height: 220,
                    child: _OutstandingContent(
                      title: 'Sales Outstanding',
                      icon: Icons.trending_up,
                      iconColor: Color(0xFF3B82F6),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                DashboardHoverPanel(
                  accentColor: const Color(0xFF8B5CF6),
                  child: const SizedBox(
                    height: 220,
                    child: _OutstandingContent(
                      title: 'Purchase Outstanding',
                      icon: Icons.shopping_cart_outlined,
                      iconColor: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OutstandingContent extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const _OutstandingContent({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF444444),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₹0.00',
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Total Outstanding',
                  style: TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}