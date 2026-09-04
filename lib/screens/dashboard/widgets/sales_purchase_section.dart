import 'package:flutter/material.dart';

import 'dashboard_metric_card.dart';
import 'dashboard_section_header.dart';

class SalesPurchaseSection extends StatelessWidget {
  const SalesPurchaseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DashboardSectionHeader(
          title: 'Sales, Purchase & Customers',
          icon: Icons.show_chart,
        ),

        const SizedBox(height: 20),

        DashboardMetricGrid(
          children: const [
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

        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 700) {
              return const Row(
                children: [
                  Expanded(
                    child: _OutstandingCard(
                      title: 'Sales Outstanding',
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _OutstandingCard(
                      title: 'Purchase Outstanding',
                    ),
                  ),
                ],
              );
            }

            return const Column(
              children: [
                _OutstandingCard(
                  title: 'Sales Outstanding',
                ),
                SizedBox(height: 18),
                _OutstandingCard(
                  title: 'Purchase Outstanding',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OutstandingCard extends StatelessWidget {
  final String title;

  const _OutstandingCard({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 34),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}