import 'package:flutter/material.dart';

import 'dashboard_metric_card.dart';
import 'dashboard_section_header.dart';

class InventoryOverviewSection extends StatelessWidget {
  const InventoryOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DashboardSectionHeader(
          title: 'Inventory Overview',
          icon: Icons.warehouse_outlined,
        ),

        const SizedBox(height: 20),

        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 650) {
              return const Row(
                children: [
                  Expanded(
                    child: DashboardMetricCard(
                      title: 'Stock In (Adjustments)',
                      value: '0 Units',
                      icon: Icons.south,
                      iconColor: Color(0xFF7D45D6),
                      iconBackground: Color(0xFFF1E9FC),
                      valueColor: Color(0xFF7D45D6),
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: DashboardMetricCard(
                      title: 'Stock Out (Adjustments)',
                      value: '0 Units',
                      icon: Icons.north,
                      iconColor: Color(0xFF7D45D6),
                      iconBackground: Color(0xFFF1E9FC),
                      valueColor: Color(0xFF7D45D6),
                    ),
                  ),
                ],
              );
            }

            return const Column(
              children: [
                DashboardMetricCard(
                  title: 'Stock In (Adjustments)',
                  value: '0 Units',
                  icon: Icons.south,
                  iconColor: Color(0xFF7D45D6),
                  iconBackground: Color(0xFFF1E9FC),
                  valueColor: Color(0xFF7D45D6),
                ),
                SizedBox(height: 14),
                DashboardMetricCard(
                  title: 'Stock Out (Adjustments)',
                  value: '0 Units',
                  icon: Icons.north,
                  iconColor: Color(0xFF7D45D6),
                  iconBackground: Color(0xFFF1E9FC),
                  valueColor: Color(0xFF7D45D6),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          height: 260,
          padding: const EdgeInsets.all(20),
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
          child: const Column(
            children: [
              Text(
                'Inventory Adjustments (Units)',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 15),

              Expanded(
                child: CustomPaint(
                  painter: _InventoryChartPainter(),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InventoryChartPainter extends CustomPainter {
  const _InventoryChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double left = 120;
    const double right = 30;
    const double top = 15;
    const double bottom = 30;

    final double chartRight = size.width - right;
    final double chartBottom = size.height - bottom;

    final Paint linePaint = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..strokeWidth = 1;

    final double middleY =
        (top + chartBottom) / 2;

    canvas.drawLine(
      Offset(left, middleY),
      Offset(chartRight, middleY),
      linePaint,
    );

    canvas.drawLine(
      Offset(left, chartBottom),
      Offset(chartRight, chartBottom),
      linePaint,
    );

    canvas.drawLine(
      Offset(left, top),
      Offset(left, chartBottom),
      linePaint,
    );

    _drawText(
      canvas,
      'Stock In (Adjustments)',
      const Offset(0, 35),
    );

    _drawText(
      canvas,
      'Stock Out (Adjustments)',
      Offset(0, middleY + 10),
    );

    _drawText(
      canvas,
      '0',
      Offset(left - 3, chartBottom + 8),
    );

    _drawText(
      canvas,
      '1',
      Offset(chartRight - 3, chartBottom + 8),
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
  ) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 9,
          color: Color(0xFF777777),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}