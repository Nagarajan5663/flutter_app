import 'package:flutter/material.dart';

import 'read_only_preview_scope.dart';
import 'summary_card.dart';

import 'profit_loss_section.dart';
import 'sales_purchase_section.dart';
import 'overdue_aging_section.dart';
import 'inventory_overview_section.dart';
import 'recent_activity_section.dart';

class DashboardBody extends StatefulWidget {
  const DashboardBody({super.key});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _CustomDateSelection {
  final DateTime start;
  final DateTime end;

  const _CustomDateSelection({required this.start, required this.end});
}

class _DashboardBodyState extends State<DashboardBody> {
  String _selectedDateRange = 'This Month';
  String? _customRangeLabel;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  static const List<String> _dateRangeOptions = [
    'This Week',
    'This Month',
    'This Year',
    'Last Week',
    'Last Month',
    'Last Year',
    'Custom Selection',
  ];

  static String _formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _openCustomDatePicker() async {
    final initialStart = _customStartDate ?? DateTime.now().subtract(const Duration(days: 30));
    final initialEnd = _customEndDate ?? DateTime.now();

    final result = await showDialog<_CustomDateSelection>(
      context: context,
      builder: (context) {
        return _CustomDateRangeDialog(
          initialStart: initialStart,
          initialEnd: initialEnd,
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _customStartDate = result.start;
      _customEndDate = result.end;
      _customRangeLabel = 'From: ${_formatDisplayDate(result.start)}  To: ${_formatDisplayDate(result.end)}';
      _selectedDateRange = 'Custom Selection';
    });
  }

  Future<void> _handleDateRangeChange(String? value) async {
    if (value == null) {
      return;
    }

    if (value == 'Custom Selection') {
      await _openCustomDatePicker();
      return;
    }

    setState(() {
      _selectedDateRange = value;
      _customRangeLabel = null;
    });
  }

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
            Color.fromARGB(0, 0, 0, 0),
            Color.fromARGB(0, 0, 0, 0),
          ],
        ),
      ),

      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ReadOnlyPreviewScope.blockActions(
          context,
          Column(
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
                        value: _selectedDateRange,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF555555),
                        ),
                        dropdownColor: Colors.white,
                        menuMaxHeight: 280,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 14,
                        ),
                        selectedItemBuilder: (context) {
                          return _dateRangeOptions.map((option) {
                            final isSelected = option == _selectedDateRange;
                            final displayText = option == 'Custom Selection' && _customRangeLabel != null
                                ? _customRangeLabel!
                                : option;

                            return Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE5E7EB) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                displayText,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        items: _dateRangeOptions.map((option) {
                          final isSelected = option == _selectedDateRange;
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFE5E7EB) : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                option,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: _handleDateRangeChange,
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

                    final double cardWidth = (constraints.maxWidth - gap) / 2;

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
      ),
    );
  }
}

class _CustomDateRangeDialog extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;

  const _CustomDateRangeDialog({
    required this.initialStart,
    required this.initialEnd,
  });

  @override
  State<_CustomDateRangeDialog> createState() => _CustomDateRangeDialogState();
}

class _CustomDateRangeDialogState extends State<_CustomDateRangeDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStart;
    _endDate = widget.initialEnd;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Select start date' : 'Select end date',
    );

    if (picked == null) {
      return;
    }

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = picked;
        if (_startDate.isAfter(_endDate)) {
          _startDate = _endDate;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Custom Date Range',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'From Date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _pickDate(true),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: Color(0xFF4B5563),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formatDate(_startDate),
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'To Date',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _pickDate(false),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: Color(0xFF4B5563),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _formatDate(_endDate),
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF374151)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        _CustomDateSelection(start: _startDate, end: _endDate),
                      );
                    },
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        color: Color(0xFF1F6FEB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

    final double chartRight = size.width - rightPadding;

    final double chartTop = topPadding;

    final double chartBottom = size.height - bottomPadding;

    final double chartWidth = chartRight - chartLeft;

    final double chartHeight = chartBottom - chartTop;

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

    final double rowHeight = chartHeight / rowCount;

    for (int i = 0; i <= rowCount; i++) {
      final double y = chartTop + (rowHeight * i);

      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartRight, y),
        gridPaint,
      );
    }

    // ==============================================================
    // THREE COLUMNS
    // ==============================================================

    final double columnWidth = chartWidth / 3;

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
      final double y = chartTop + (rowHeight * i);

      final String amount = i <= 5 ? '₹1' : '₹0';

      final TextPainter textPainter = TextPainter(
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
          chartLeft - textPainter.width - 9,
          y - (textPainter.height / 2),
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
      final double centerX = chartLeft + (columnWidth * i) + (columnWidth / 2);

      final TextPainter textPainter = TextPainter(
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
          centerX - (textPainter.width / 2),
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
