import 'package:flutter/material.dart';

import 'widgets/report_glass_widgets.dart';

class SalesByItemPage extends StatefulWidget {
  final VoidCallback onBack;

  const SalesByItemPage({
    super.key,
    required this.onBack,
  });

  @override
  State<SalesByItemPage> createState() => _SalesByItemPageState();
}

class _SalesByItemPageState extends State<SalesByItemPage> {
  String dateRange = 'Custom';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 760;

    return ReportGlassPageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportPageHeader(
            title: 'Sales by Item Report',
            actions: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ReportGlassButton(
                  label: 'Back to Reports',
                  icon: Icons.arrow_back_rounded,
                  primary: false,
                  onPressed: widget.onBack,
                ),
                ReportGlassButton(
                  label: 'Export PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 38),
            child: ReportDateFilterCard(
              dateRange: dateRange,
              dateFrom: '01-09-2026',
              dateTo: '14-09-2026',
              onDateRangeChanged: (value) {
                if (value != null) setState(() => dateRange = value);
              },
              onRunReport: () {},
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 18 : 38,
              0,
              isMobile ? 18 : 38,
              isMobile ? 20 : 38,
            ),
            child: _ItemTable(),
          ),
        ],
      ),
    );
  }
}

class _ItemTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const minWidth = 760.0;

    return ReportGlassCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    color: Colors.white.withValues(alpha: 0.25),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: ReportTableHeaderText('ITEM NAME')),
                        Expanded(flex: 2, child: ReportTableHeaderText('SKU')),
                        Expanded(flex: 2, child: ReportTableHeaderText('QUANTITY SOLD')),
                        Expanded(
                          flex: 2,
                          child: ReportTableHeaderText('SALES AMOUNT', textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 38, horizontal: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'No sales data found for the selected period.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Color(0xFF667A8A)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
