import 'package:flutter/material.dart';
import 'dashboard_metric_card.dart';

class InventoryOverviewSection extends StatelessWidget {
  const InventoryOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ====================================================================
        // TITLE
        // ====================================================================

        const Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: Colors.white,
              size: 22,
            ),

            SizedBox(width: 8),

            Text(
              'Inventory Overview',
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
          thickness: 1,
          height: 1,
          color: Colors.white38,
        ),

        const SizedBox(height: 20),

        // ====================================================================
        // INVENTORY CARDS
        // ====================================================================

        const DashboardMetricGrid(
          children: [
            // ----------------------------------------------------------------
            // STOCK IN
            // ----------------------------------------------------------------

            DashboardMetricCard(
              title: 'Stock In (Adjustments)',
              value: '0',
              icon: Icons.move_to_inbox_outlined,
              iconColor: Color(0xFF22C55E),
              iconBackground: Color(0xFFDCFCE7),
              valueColor: Color(0xFF22C55E),
            ),

            // ----------------------------------------------------------------
            // STOCK OUT
            // ----------------------------------------------------------------

            DashboardMetricCard(
              title: 'Stock Out (Adjustments)',
              value: '0',
              icon: Icons.outbox_outlined,
              iconColor: Color(0xFFF59E0B),
              iconBackground: Color(0xFFFEF3C7),
              valueColor: Color(0xFFF59E0B),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ====================================================================
        // INVENTORY ADJUSTMENTS CHART
        // ====================================================================

        DashboardHoverPanel(
          accentColor: Color(0xFF3B82F6),

          padding: EdgeInsets.fromLTRB(
            20,
            22,
            20,
            18,
          ),

          child: Column(
            children: [
              // ----------------------------------------------------------------
              // CHART HEADER
              // ----------------------------------------------------------------

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _InventoryIcon(),

                  SizedBox(width: 10),

                  Text(
                    'Inventory Adjustments (Units)',
                    style: TextStyle(
                      color: Color(0xFF444444),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // ----------------------------------------------------------------
              // CHART
              // ----------------------------------------------------------------

              SizedBox(
                height: 280,
                width: double.infinity,
                child: CustomPaint(
                  painter: _InventoryChartPainter(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// INVENTORY ICON
// ============================================================================

class _InventoryIcon extends StatelessWidget {
  const _InventoryIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,

      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        shape: BoxShape.circle,
      ),

      child: const Icon(
        Icons.inventory_2_outlined,
        size: 20,
        color: Color(0xFF3B82F6),
      ),
    );
  }
}

// ============================================================================
// INVENTORY CHART PAINTER
// ============================================================================

class _InventoryChartPainter extends CustomPainter {
  const _InventoryChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPadding = 45;
    const double rightPadding = 20;
    const double topPadding = 15;
    const double bottomPadding = 40;

    final double chartLeft = leftPadding;
    final double chartRight = size.width - rightPadding;
    final double chartTop = topPadding;
    final double chartBottom = size.height - bottomPadding;

    final double chartWidth = chartRight - chartLeft;
    final double chartHeight = chartBottom - chartTop;

    // ========================================================================
    // GRID
    // ========================================================================

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    final Paint axisPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1;

    const int rows = 5;

    final double rowHeight = chartHeight / rows;

    for (int i = 0; i <= rows; i++) {
      final double y = chartTop + (rowHeight * i);

      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartRight, y),
        gridPaint,
      );
    }

    // LEFT AXIS
    canvas.drawLine(
      Offset(chartLeft, chartTop),
      Offset(chartLeft, chartBottom),
      axisPaint,
    );

    // BOTTOM AXIS
    canvas.drawLine(
      Offset(chartLeft, chartBottom),
      Offset(chartRight, chartBottom),
      axisPaint,
    );

    // ========================================================================
    // Y AXIS LABELS
    // ========================================================================

    for (int i = 0; i <= rows; i++) {
      final int value = (rows - i) * 20;

      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: value.toString(),
          style: const TextStyle(
            color: Color(0xFF777777),
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      painter.layout();

      final double y = chartTop + rowHeight * i;

      painter.paint(
        canvas,
        Offset(
          chartLeft - painter.width - 8,
          y - painter.height / 2,
        ),
      );
    }

    // ========================================================================
    // BARS
    // ========================================================================

    final Paint greenPaint = Paint()
      ..color = const Color(0xFF22C55E);

    final Paint orangePaint = Paint()
      ..color = const Color(0xFFF59E0B);

    final double center = chartLeft + chartWidth / 2;

    const double barWidth = 55;

    // Stock In
    final Rect stockInBar = Rect.fromLTWH(
      center - barWidth - 15,
      chartBottom - 1,
      barWidth,
      1,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        stockInBar,
        const Radius.circular(4),
      ),
      greenPaint,
    );

    // Stock Out
    final Rect stockOutBar = Rect.fromLTWH(
      center + 15,
      chartBottom - 1,
      barWidth,
      1,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        stockOutBar,
        const Radius.circular(4),
      ),
      orangePaint,
    );

    // ========================================================================
    // BOTTOM LABELS
    // ========================================================================

    final TextPainter stockInText = TextPainter(
      text: const TextSpan(
        text: 'Stock In',
        style: TextStyle(
          color: Color(0xFF555555),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    stockInText.layout();

    stockInText.paint(
      canvas,
      Offset(
        center - barWidth - 15 + (barWidth - stockInText.width) / 2,
        chartBottom + 10,
      ),
    );

    final TextPainter stockOutText = TextPainter(
      text: const TextSpan(
        text: 'Stock Out',
        style: TextStyle(
          color: Color(0xFF555555),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    stockOutText.layout();

    stockOutText.paint(
      canvas,
      Offset(
        center + 15 + (barWidth - stockOutText.width) / 2,
        chartBottom + 10,
      ),
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}