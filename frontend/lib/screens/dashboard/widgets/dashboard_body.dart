import 'package:flutter/material.dart';

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
      width: double.infinity,

      // ============================================================
      // DASHBOARD BACKGROUND
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
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // DASHBOARD TITLE
            // ======================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                width: 150,
                height: 42,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'This Month',
                    isExpanded: true,

                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF555555),
                    ),

                      style: const TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 14,
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: 'This Month',
                          child: Text('This Month'),
                        ),
                        DropdownMenuItem(
                          value: 'Last Month',
                          child: Text('Last Month'),
                        ),
                        DropdownMenuItem(
                          value: 'This Year',
                          child: Text('This Year'),
                        ),
                      ],

                      onChanged: (value) {},
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ======================================================
            // CASH FLOW OVERVIEW HEADER
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

            // ======================================================
            // CASH FLOW CARDS
            //
            // WEB     = 4 CARDS IN ONE ROW
            // TABLET  = 2 CARDS PER ROW
            // MOBILE  = 1 CARD PER ROW
            // ======================================================
            LayoutBuilder(
              builder: (context, constraints) {
                // --------------------------------------------------
                // LARGE WEB SCREEN
                // --------------------------------------------------
                if (constraints.maxWidth >= 900) {
                  return const Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 110,
                          child: SummaryCard(
                            title: 'Total Revenue',
                            amount: '₹0.00',
                            icon: Icons.trending_up,
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      Expanded(
                        child: SizedBox(
                          height: 110,
                          child: SummaryCard(
                            title: 'Total Expenses',
                            amount: '₹0.00',
                            icon: Icons.trending_down,
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      Expanded(
                        child: SizedBox(
                          height: 110,
                          child: SummaryCard(
                            title: 'Cost of Goods',
                            amount: '₹0.00',
                            icon: Icons.shopping_cart_outlined,
                          ),
                        ),
                      ),

                      SizedBox(width: 16),

                      Expanded(
                        child: SizedBox(
                          height: 110,
                          child: SummaryCard(
                            title: 'Net Cash Flow',
                            amount: '₹0.00',
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // --------------------------------------------------
                // TABLET
                // --------------------------------------------------
                if (constraints.maxWidth >= 500) {
                  const double gap = 12;

                  final double cardWidth =
                      (constraints.maxWidth - gap) / 2;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        height: 110,
                        child: const SummaryCard(
                          title: 'Total Revenue',
                          amount: '₹0.00',
                          icon: Icons.trending_up,
                        ),
                      ),

                      SizedBox(
                        width: cardWidth,
                        height: 110,
                        child: const SummaryCard(
                          title: 'Total Expenses',
                          amount: '₹0.00',
                          icon: Icons.trending_down,
                        ),
                      ),

                      SizedBox(
                        width: cardWidth,
                        height: 110,
                        child: const SummaryCard(
                          title: 'Cost of Goods',
                          amount: '₹0.00',
                          icon: Icons.shopping_cart_outlined,
                        ),
                      ),

                      SizedBox(
                        width: cardWidth,
                        height: 110,
                        child: const SummaryCard(
                          title: 'Net Cash Flow',
                          amount: '₹0.00',
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      ),
                    ],
                  );
                }

                // --------------------------------------------------
                // MOBILE
                // --------------------------------------------------
                return const Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 110,
                      child: SummaryCard(
                        title: 'Total Revenue',
                        amount: '₹0.00',
                        icon: Icons.trending_up,
                      ),
                    ),

                    SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 110,
                      child: SummaryCard(
                        title: 'Total Expenses',
                        amount: '₹0.00',
                        icon: Icons.trending_down,
                      ),
                    ),

                    SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 110,
                      child: SummaryCard(
                        title: 'Cost of Goods',
                        amount: '₹0.00',
                        icon: Icons.shopping_cart_outlined,
                      ),
                    ),

                    SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 110,
                      child: SummaryCard(
                        title: 'Net Cash Flow',
                        amount: '₹0.00',
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // ======================================================
            // CASH FLOW SUMMARY
            // ======================================================
            const _CashFlowSummaryCard(),

            const SizedBox(height: 40),

            // ======================================================
            // PROFIT & LOSS OVERVIEW
            // ======================================================
            const ProfitLossSection(),

            const SizedBox(height: 40),

            // ======================================================
            // SALES, PURCHASE & CUSTOMERS
            // ======================================================
            const SalesPurchaseSection(),

            const SizedBox(height: 40),

            // ======================================================
            // OVERDUE RECEIVABLES AGING
            // ======================================================
            const OverdueAgingSection(),

            const SizedBox(height: 40),

            // ======================================================
            // INVENTORY OVERVIEW
            // ======================================================
            const InventoryOverviewSection(),

            const SizedBox(height: 40),

            // ======================================================
            // RECENT ACTIVITY
            // ======================================================
            const RecentActivitySection(),

            const SizedBox(height: 35),

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
// CASH FLOW SUMMARY CARD
// ====================================================================

class _CashFlowSummaryCard extends StatelessWidget {
  const _CashFlowSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: const Column(
        children: [
          SizedBox(height: 30),

          // ========================================================
          // TITLE
          // ========================================================
          Text(
            'Cash Flow Summary (This Month)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF555555),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 10),

          // ========================================================
          // CHART
          // ========================================================
          SizedBox(
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
// CASH FLOW SUMMARY GRID
// ====================================================================

class _CashFlowSummaryGridPainter extends CustomPainter {
  const _CashFlowSummaryGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // ==============================================================
    // CHART SPACING
    // ==============================================================

    const double leftPadding = 48;
    const double rightPadding = 20;
    const double topPadding = 5;
    const double bottomPadding = 45;

    final double chartLeft = leftPadding;

    final double chartRight =
        size.width - rightPadding;

    final double chartTop = topPadding;

    final double chartBottom =
        size.height - bottomPadding;

    final double chartWidth =
        chartRight - chartLeft;

    final double chartHeight =
        chartBottom - chartTop;

    // ==============================================================
    // GRID PAINT
    // ==============================================================

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE4E4E4)
      ..strokeWidth = 1;

    final Paint axisPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..strokeWidth = 1;

    // ==============================================================
    // HORIZONTAL ROWS
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
    // THREE COLUMNS
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
    // Y AXIS VALUES
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

      // SMALL TICK
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