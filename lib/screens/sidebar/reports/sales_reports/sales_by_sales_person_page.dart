import 'package:flutter/material.dart';

import 'widgets/report_glass_widgets.dart';

class SalesBySalesPersonPage extends StatefulWidget {
  final VoidCallback onBack;

  const SalesBySalesPersonPage({
    super.key,
    required this.onBack,
  });

  @override
  State<SalesBySalesPersonPage> createState() => _SalesBySalesPersonPageState();
}

class _SalesBySalesPersonPageState extends State<SalesBySalesPersonPage> {
  String dateRange = 'Custom';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 760;

    return ReportGlassPageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportPageHeader(
            title: 'Sales by Sales Person',
            actions: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ReportGlassButton(
                  label: 'Back to Sales Reports',
                  icon: Icons.arrow_back_rounded,
                  primary: false,
                  onPressed: widget.onBack,
                ),
                ReportGlassButton(
                  label: 'Download PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  backgroundColor: const Color(0xFFE9574F),
                  onPressed: () {},
                ),
                ReportGlassButton(
                  label: 'Download Excel (CSV)',
                  icon: Icons.table_view_outlined,
                  backgroundColor: const Color(0xFF27B463),
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
            child: _SalesPersonTable(),
          ),
        ],
      ),
    );
  }
}

class _SalesPersonTable extends StatelessWidget {
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
                        Expanded(flex: 4, child: ReportTableHeaderText('SALES PERSON NAME')),
                        Expanded(flex: 2, child: ReportTableHeaderText('SALES ORDER COUNT')),
                        Expanded(
                          flex: 2,
                          child: ReportTableHeaderText('TOTAL AMOUNT', textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'No sales data found for any sales person.',
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
