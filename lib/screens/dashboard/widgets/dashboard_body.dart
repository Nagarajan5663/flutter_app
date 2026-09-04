import 'package:flutter/material.dart';
import 'glass_container.dart';

import 'summary_card.dart';

import 'profit_loss_section.dart';
import 'sales_purchase_section.dart';
import 'overdue_aging_section.dart';
import 'inventory_overview_section.dart';
import 'recent_activity_section.dart';

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // ============================================================
      // KEEPING YOUR EXISTING CUSTOM BACKGROUND
      // ============================================================
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D2B4E),
            Color(0xFF123A5C),
          ],
        ),
      ),

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // DASHBOARD TITLE + MONTH DROPDOWN
            // ======================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'WELCOME,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

                

            // ======================================================
            // CASH FLOW OVERVIEW
            // ======================================================
            const Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 22,
                  color: Colors.white,
                ),

                SizedBox(width: 8),

                Text(
                  'Cash Flow Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Divider(
              thickness: 1,
              height: 1,
              color: Colors.white54,
            ),

            const SizedBox(height: 18),

            // ======================================================
            // YOUR EXISTING 4 SUMMARY CARDS
            // ======================================================
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,

              children: const [
                SummaryCard(
                  title: 'Total Revenue',
                  amount: '₹0.00',
                  icon: Icons.trending_up,
                ),

                SummaryCard(
                  title: 'Total Expenses',
                  amount: '₹0.00',
                  icon: Icons.trending_down,
                ),

                SummaryCard(
                  title: 'Cost of Goods',
                  amount: '₹0.00',
                  icon: Icons.shopping_cart,
                ),

                SummaryCard(
                  title: 'Net Cash Flow',
                  amount: '₹0.00',
                  icon: Icons.account_balance_wallet,
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ======================================================
            // CASH FLOW SUMMARY CARD
            // ======================================================
            const _CashFlowSummaryCard(),

            // ======================================================
            // NEW SECTIONS START HERE
            // ======================================================
            const SizedBox(height: 35),

            // ======================================================
            // PROFIT & LOSS OVERVIEW
            // ======================================================
            const ProfitLossSection(),

            const SizedBox(height: 35),

            // ======================================================
            // SALES, PURCHASE & CUSTOMERS
            // ======================================================
            const SalesPurchaseSection(),

            const SizedBox(height: 35),

            // ======================================================
            // OVERDUE RECEIVABLES AGING
            // ======================================================
            const OverdueAgingSection(),

            const SizedBox(height: 35),

            // ======================================================
            // INVENTORY OVERVIEW
            // ======================================================
            const InventoryOverviewSection(),

            const SizedBox(height: 35),

            // ======================================================
            // RECENT ACTIVITY
            // ======================================================
            const RecentActivitySection(),

            const SizedBox(height: 30),

            // ======================================================
            // FOOTER
            // ======================================================
            const Center(
              child: Text(
                '© 2026 test. All Rights Reserved.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ====================================================================
// CASH FLOW SUMMARY
// ====================================================================
class _CashFlowSummaryCard extends StatelessWidget {
  const _CashFlowSummaryCard();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,

      // More opaque because chart needs good visibility
      opacity: 0.88,

      blur: 18,

      child: Column(
        children: [
          const SizedBox(height: 30),

          const Text(
            'Cash Flow Summary (This Month)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF5F6368),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const SizedBox(
            height: 430,
            width: double.infinity,
            child: CustomPaint(
              painter: _CashFlowSummaryGridPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// CASH FLOW SUMMARY GRID PAINTER
// ====================================================================
class _CashFlowSummaryGridPainter extends CustomPainter {
  const _CashFlowSummaryGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // ==============================================================
    // CHART DIMENSIONS
    // ==============================================================
    const double leftPadding = 48;
    const double rightPadding = 20;
    const double topPadding = 5;
    const double bottomPadding = 45;

    final double chartLeft = leftPadding;
    final double chartRight = size.width - rightPadding;

    final double chartTop = topPadding;
    final double chartBottom =
        size.height - bottomPadding;

    final double chartWidth =
        chartRight - chartLeft;

    final double chartHeight =
        chartBottom - chartTop;

    // ==============================================================
    // GRID STYLE
    // ==============================================================
    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE4E4E4)
      ..strokeWidth = 1;

    final Paint axisPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1;

    // ==============================================================
    // 10 HORIZONTAL ROWS
    // ==============================================================
    const int rowCount = 10;

    final double rowHeight =
        chartHeight / rowCount;

    for (int i = 0; i <= rowCount; i++) {
      final double y =
          chartTop + (rowHeight * i);

      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartRight, y),
        gridPaint,
      );
    }

    // ==============================================================
    // THREE EQUAL COLUMNS
    // ==============================================================
    final double columnWidth =
        chartWidth / 3;

    // LEFT VERTICAL LINE
    canvas.drawLine(
      Offset(
        chartLeft,
        chartTop,
      ),
      Offset(
        chartLeft,
        chartBottom,
      ),
      axisPaint,
    );

    // FIRST DIVIDER
    canvas.drawLine(
      Offset(
        chartLeft + columnWidth,
        chartTop,
      ),
      Offset(
        chartLeft + columnWidth,
        chartBottom,
      ),
      gridPaint,
    );

    // SECOND DIVIDER
    canvas.drawLine(
      Offset(
        chartLeft + (columnWidth * 2),
        chartTop,
      ),
      Offset(
        chartLeft + (columnWidth * 2),
        chartBottom,
      ),
      gridPaint,
    );

    // ==============================================================
    // Y-AXIS LABELS
    // ==============================================================
    for (int i = 0; i <= rowCount; i++) {
      final double y =
          chartTop + (rowHeight * i);

      final String amount =
          i <= 5 ? '₹1' : '₹0';

      final TextPainter textPainter =
          TextPainter(
        text: TextSpan(
          text: amount,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          chartLeft -
              textPainter.width -
              9,
          y -
              (textPainter.height / 2),
        ),
      );

      // SMALL TICK LINE
      canvas.drawLine(
        Offset(
          chartLeft - 6,
          y,
        ),
        Offset(
          chartLeft,
          y,
        ),
        axisPaint,
      );
    }

    // ==============================================================
    // BOTTOM LABELS
    // ==============================================================
    const List<String> labels = [
      'Total Revenue',
      'Total Expenses',
      'Net Cash Flow',
    ];

    for (int i = 0; i < labels.length; i++) {
      final double centerX =
          chartLeft +
          (columnWidth * i) +
          (columnWidth / 2);

      final TextPainter textPainter =
          TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          centerX -
              (textPainter.width / 2),
          chartBottom + 12,
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