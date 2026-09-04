import 'package:flutter/material.dart';

import 'dashboard_section_header.dart';

class OverdueAgingSection extends StatelessWidget {
  const OverdueAgingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DashboardSectionHeader(
          title: 'Overdue Receivables Aging',
          icon: Icons.warning_amber_rounded,
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          height: 260,
          padding: const EdgeInsets.fromLTRB(
            22,
            25,
            22,
            18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
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
              const Padding(
                padding: EdgeInsets.only(left: 50),
                child: Text(
                  'Overdue Receivables by Aging Period',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double chartWidth =
                        constraints.maxWidth >= 700
                            ? constraints.maxWidth * 0.43
                            : constraints.maxWidth;

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: chartWidth,
                        child: const CustomPaint(
                          painter: _OverdueAgingPainter(),
                          size: Size.infinite,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverdueAgingPainter extends CustomPainter {
  const _OverdueAgingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double left = 34;
    const double right = 5;
    const double top = 2;
    const double bottom = 35;

    final double chartRight = size.width - right;
    final double chartBottom = size.height - bottom;

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..strokeWidth = 1;

    final Paint axisPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1;

    const int horizontalLines = 5;

    for (int i = 0; i <= horizontalLines; i++) {
      final double y =
          top +
          ((chartBottom - top) / horizontalLines) * i;

      canvas.drawLine(
        Offset(left, y),
        Offset(chartRight, y),
        gridPaint,
      );
    }

    const int columns = 4;

    for (int i = 0; i <= columns; i++) {
      final double x =
          left +
          ((chartRight - left) / columns) * i;

      canvas.drawLine(
        Offset(x, top),
        Offset(x, chartBottom),
        i == 0 ? axisPaint : gridPaint,
      );
    }

    const List<String> yLabels = [
      '₹1',
      '₹1',
      '₹1',
      '₹0',
      '₹0',
      '₹0',
    ];

    for (int i = 0; i < yLabels.length; i++) {
      final double y =
          top +
          ((chartBottom - top) /
                  (yLabels.length - 1)) *
              i;

      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: yLabels[i],
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF666666),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      painter.layout();

      painter.paint(
        canvas,
        Offset(
          left - painter.width - 7,
          y - painter.height / 2,
        ),
      );
    }

    const List<String> labels = [
      '1-15 Days',
      '16-30 Days',
      '31-60 Days',
      '60+ Days',
    ];

    final double columnWidth =
        (chartRight - left) / columns;

    for (int i = 0; i < labels.length; i++) {
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF666666),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      painter.layout();

      final double center =
          left +
          (columnWidth * i) +
          columnWidth / 2;

      painter.paint(
        canvas,
        Offset(
          center - painter.width / 2,
          chartBottom + 10,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}