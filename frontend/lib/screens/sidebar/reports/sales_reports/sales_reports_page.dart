import 'package:flutter/material.dart';

import 'sales_by_customer_page.dart';
import 'sales_by_item_page.dart';
import 'sales_by_sales_person_page.dart';
import 'sales_summary_page.dart';
import 'widgets/report_glass_widgets.dart';

enum SalesReportView {
  list,
  customer,
  item,
  salesPerson,
  summary,
}

class SalesReportsPage extends StatefulWidget {
  final VoidCallback? onBackToAllReports;

  const SalesReportsPage({
    super.key,
    this.onBackToAllReports,
  });

  @override
  State<SalesReportsPage> createState() => _SalesReportsPageState();
}

class _SalesReportsPageState extends State<SalesReportsPage> {
  SalesReportView _view = SalesReportView.list;

  void _open(SalesReportView view) {
    setState(() => _view = view);
  }

  void _backToSalesReports() {
    setState(() => _view = SalesReportView.list);
  }

  @override
  Widget build(BuildContext context) {
    switch (_view) {
      case SalesReportView.customer:
        return SalesByCustomerPage(onBack: _backToSalesReports);
      case SalesReportView.item:
        return SalesByItemPage(onBack: _backToSalesReports);
      case SalesReportView.salesPerson:
        return SalesBySalesPersonPage(onBack: _backToSalesReports);
      case SalesReportView.summary:
        return SalesSummaryPage(onBack: _backToSalesReports);
      case SalesReportView.list:
        return _buildList();
    }
  }

  Widget _buildList() {
    final isMobile = MediaQuery.of(context).size.width < 760;

    return ReportGlassPageSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReportPageHeader(
            title: 'Sales Reports',
            actions: ReportGlassButton(
              label: 'Back to All Reports',
              icon: Icons.arrow_back_rounded,
              primary: false,
              onPressed: widget.onBackToAllReports ?? () {},
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 18 : 38,
              0,
              isMobile ? 18 : 38,
              isMobile ? 20 : 38,
            ),
            child: ReportGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 17, 18, 16),
                    child: Text(
                      'Sales',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ReportGlassTheme.navy,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.70)),
                  _SalesReportTable(
                    onCustomer: () => _open(SalesReportView.customer),
                    onItem: () => _open(SalesReportView.item),
                    onSalesPerson: () => _open(SalesReportView.salesPerson),
                    onSummary: () => _open(SalesReportView.summary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesReportTable extends StatelessWidget {
  final VoidCallback onCustomer;
  final VoidCallback onItem;
  final VoidCallback onSalesPerson;
  final VoidCallback onSummary;

  const _SalesReportTable({
    required this.onCustomer,
    required this.onItem,
    required this.onSalesPerson,
    required this.onSummary,
  });

  @override
  Widget build(BuildContext context) {
    const minWidth = 760.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  color: Colors.white.withValues(alpha: 0.25),
                  child: const Row(
                    children: [
                      Expanded(flex: 4, child: ReportTableHeaderText('REPORT NAME')),
                      Expanded(flex: 3, child: ReportTableHeaderText('LAST VISITED')),
                      Expanded(flex: 3, child: ReportTableHeaderText('CREATED BY')),
                    ],
                  ),
                ),
                _row('Sales by Customer', '26/09/2025 03:26 PM', 'System Generated', onCustomer),
                _row('Sales by Item', '08/04/2025 12:45 PM', 'System Generated', onItem),
                _row('Sales by Sales Person', '01/10/2025 11:15 AM', 'System Generated', onSalesPerson),
                _row('Sales Summary', '-', 'System Generated', onSummary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String name, String lastVisited, String createdBy, VoidCallback onTap) {
    return _HoverRow(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF278BC2),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(lastVisited, style: const TextStyle(fontSize: 13, color: Color(0xFF314758))),
            ),
            Expanded(
              flex: 3,
              child: Text(createdBy, style: const TextStyle(fontSize: 13, color: Color(0xFF314758))),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverRow extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverRow({required this.child, required this.onTap});

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: hover ? Colors.white.withValues(alpha: 0.32) : Colors.transparent,
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.60)),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
