import 'package:flutter/material.dart';

import 'dashboard_metric_card.dart';
import 'dashboard_section_header.dart';

class SalesPurchaseSection extends StatelessWidget {
  const SalesPurchaseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ============================================================
        // SECTION HEADER
        // ============================================================

        const DashboardSectionHeader(
          title: 'Sales, Purchase & Customers',
          icon: Icons.show_chart,
        ),

        const SizedBox(height: 20),

        // ============================================================
        // METRIC CARDS
        // ============================================================

        const DashboardMetricGrid(
          children: [
            DashboardMetricCard(
              title: 'Current Outstanding',
              value: '₹0',
              icon: Icons.request_quote_outlined,
              iconColor: Color(0xFFFFC107),
              iconBackground: Color(0xFFFFF8DD),
              valueColor: Color(0xFFFFB300),
            ),

            DashboardMetricCard(
              title: 'Overdue Outstanding',
              value: '₹0',
              icon: Icons.access_time_filled,
              iconColor: Color(0xFFE63E50),
              iconBackground: Color(0xFFFCEAEC),
              valueColor: Color(0xFFE63E50),
            ),

            DashboardMetricCard(
              title: 'New Customers',
              value: '0',
              icon: Icons.person_add_alt_1,
              iconColor: Color(0xFF1688E5),
              iconBackground: Color(0xFFE7F3FE),
              valueColor: Color(0xFF1688E5),
            ),

            DashboardMetricCard(
              title: 'Current Payables',
              value: '₹0',
              icon: Icons.receipt_long,
              iconColor: Color(0xFFFF8300),
              iconBackground: Color(0xFFFFF0E4),
              valueColor: Color(0xFFFF8300),
            ),

            DashboardMetricCard(
              title: 'Overdue Payables',
              value: '₹0',
              icon: Icons.event_busy,
              iconColor: Color(0xFFE63E50),
              iconBackground: Color(0xFFFCEAEC),
              valueColor: Color(0xFFE63E50),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // ============================================================
        // SALES + PURCHASE OUTSTANDING
        // ============================================================

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
                        child: _OutstandingCard(
                          title: 'Sales Outstanding',
                          icon: Icons.trending_up,
                          accentColor: Color(0xFF3B82F6),
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
                        child: _OutstandingCard(
                          title: 'Purchase Outstanding',
                          icon: Icons.shopping_cart_outlined,
                          accentColor: Color(0xFF8B5CF6),
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
                    child: _OutstandingCard(
                      title: 'Sales Outstanding',
                      icon: Icons.trending_up,
                      accentColor: Color(0xFF3B82F6),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                DashboardHoverPanel(
                  accentColor: const Color(0xFF8B5CF6),
                  child: const SizedBox(
                    height: 220,
                    child: _OutstandingCard(
                      title: 'Purchase Outstanding',
                      icon: Icons.shopping_cart_outlined,
                      accentColor: Color(0xFF8B5CF6),
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

// ============================================================================
// OUTSTANDING CARD CONTENT
// ============================================================================

class _OutstandingCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accentColor;

  const _OutstandingCard({
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF444444),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        Text(
          '₹0.00',
          style: TextStyle(
            color: accentColor,
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
    );
  }
}