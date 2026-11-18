import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/sales_glass_widgets.dart';

import '../widgets/sales_dialog_helpers.dart';
import 'invoice_filter.dart';
import 'invoice_model.dart';
import 'invoice_repository.dart';
import 'widgets/add_invoice_dialog.dart';

class InvoicesPage extends StatefulWidget {
  final VoidCallback? onOpenDeliveryChallans;
  final VoidCallback? onOpenPaymentsReceived;

  const InvoicesPage({
    super.key,
    this.onOpenDeliveryChallans,
    this.onOpenPaymentsReceived,
  });

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final InvoiceRepository _repository = InMemoryInvoiceRepository();

  List<InvoiceModel> _invoices = [];
  List<InvoiceModel> _allInvoices = [];
  bool _isLoading = true;

  final customerController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;
  bool _showFilters = false;

  String statusFilter = 'All';
  final statusOptions = const ['All', 'Unpaid', 'Partially Paid', 'Paid'];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  @override
  void dispose() {
    customerController.dispose();
    super.dispose();
  }

  InvoiceFilter get _currentFilter => InvoiceFilter(
        status: statusFilter,
        customerName: customerController.text,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    final result = await _repository.getInvoices();
    if (!mounted) return;
    setState(() {
      _allInvoices = result;
      _invoices = result.where(_currentFilter.matches).toList();
      _isLoading = false;
    });
  }

  Future<void> _openAddInvoice() async {
    final invoice = await showDialog<InvoiceModel>(
      context: context,
      barrierColor: const Color(0x9A12202C),
      barrierDismissible: false,
      builder: (_) => const AddInvoiceDialog(),
    );
    if (!mounted || invoice == null) return;
    await _repository.addInvoice(invoice);
    await _loadInvoices();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice created successfully')));
  }

  Future<void> _deleteInvoice(InvoiceModel invoice) async {
    if (invoice.id == null) return;
    await _repository.deleteInvoice(invoice.id!);
    await _loadInvoices();
  }

  void _clearFilters() {
    statusFilter = 'All';
    customerController.clear();
    dateFrom = null;
    dateTo = null;
    _loadInvoices();
  }

  String _currency(double amount) =>
      '₹${NumberFormat('#,##0.00', 'en_IN').format(amount)}';

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  double _receivableAmount(InvoiceModel invoice) {
    if (invoice.total > 0 &&
        invoice.amountDue <= 0 &&
        invoice.dueDate == null) {
      return invoice.total;
    }
    return invoice.amountDue;
  }

  double _balanceForDueInvoices(bool Function(DateTime dueDate) matches) {
    return _allInvoices.fold<double>(0, (total, invoice) {
      final dueDate = invoice.dueDate ?? invoice.date;
      final receivableAmount = _receivableAmount(invoice);
      if (receivableAmount <= 0 || !matches(_dateOnly(dueDate))) {
        return total;
      }
      return total + receivableAmount;
    });
  }

  String _dueStatus(InvoiceModel invoice) {
    final effectiveAmount = _receivableAmount(invoice);
    if (effectiveAmount <= 0) return 'PAID';
    final dueDate = invoice.dueDate ?? invoice.date;

    final daysUntilDue =
        _dateOnly(dueDate).difference(_dateOnly(DateTime.now())).inDays;
    if (daysUntilDue < 0) return 'OVERDUE BY ${-daysUntilDue} DAYS';
    if (daysUntilDue == 0) return 'DUE TODAY';
    return 'DUE IN $daysUntilDue DAYS';
  }

  Color _dueStatusColor(InvoiceModel invoice) {
    if (invoice.amountDue <= 0) return const Color(0xFF1E7B34);
    final dueDate = invoice.dueDate;
    if (dueDate != null &&
        _dateOnly(dueDate).isBefore(_dateOnly(DateTime.now()))) {
      return const Color(0xFFAB2A2A);
    }
    return const Color(0xFF3886A8);
  }

  Color _dueStatusBg(InvoiceModel invoice) {
    if (invoice.amountDue <= 0) return const Color(0xFFE3F6E8);
    final dueDate = invoice.dueDate;
    if (dueDate != null &&
        _dateOnly(dueDate).isBefore(_dateOnly(DateTime.now()))) {
      return const Color(0xFFF4E3E3);
    }
    return const Color(0xFFE5F3F8);
  }

  Widget _paymentSummary() {
    final today = _dateOnly(DateTime.now());
    final endOfNext30Days = today.add(const Duration(days: 30));
    final outstanding = _allInvoices.fold<double>(
      0,
      (total, invoice) => total + _receivableAmount(invoice),
    );
    final dueToday = _balanceForDueInvoices((date) => date == today);
    final dueWithin30Days = _balanceForDueInvoices(
      (date) => !date.isBefore(today) && !date.isAfter(endOfNext30Days),
    );
    final overdue = _balanceForDueInvoices((date) => date.isBefore(today));
    final metrics = [
      (
        label: 'Total Outstanding Receivables',
        value: _currency(outstanding),
        color: const Color(0xFF263746),
      ),
      (
        label: 'Due Today',
        value: _currency(dueToday),
        color: const Color(0xFFC6655B),
      ),
      (
        label: 'Due Within 30 Days',
        value: _currency(dueWithin30Days),
        color: const Color(0xFF263746),
      ),
      (
        label: 'Overdue Invoices',
        value: _currency(overdue),
        color: const Color(0xFF263746),
      ),
      (
        label: 'Average Days to Get Paid',
        value: '—',
        color: const Color(0xFF263746),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x4FFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xC7FFFFFF)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 12.0;
          final columns = constraints.maxWidth >= 1100
              ? 5
              : constraints.maxWidth >= 700
                  ? 3
                  : 1;
          final cardWidth =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: metrics
                .map(
                  (metric) => SizedBox(
                    width: cardWidth,
                    child: _InvoiceSummaryMetric(
                      label: metric.label,
                      value: metric.value,
                      valueColor: metric.color,
                      helperText: metric.label == 'Average Days to Get Paid'
                          ? 'Payment dates are not recorded'
                          : null,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SalesGlassPageFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Invoices',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123456))),
                ),
                SalesFilterButton(
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _openAddInvoice,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF123456),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'PAYMENT SUMMARY',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF536273),
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            _paymentSummary(),
            const SizedBox(height: 20),
            if (_showFilters)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0x4FFFFFFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xC7FFFFFF)),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5B5B5B))),
                        const SizedBox(height: 6),
                        Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0x6EFFFFFF),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(color: const Color(0xC7FFFFFF)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: statusFilter,
                              isExpanded: true,
                              items: statusOptions
                                  .map((s) => DropdownMenuItem(
                                      value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => statusFilter = value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Customer Name',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5B5B5B))),
                        const SizedBox(height: 6),
                        SizedBox(
                            width: 180,
                            child: salesFilterTextField(
                                customerController, 'Customer name...')),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date From',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5B5B5B))),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 150,
                          child: salesFilterDateField(
                            context: context,
                            value: dateFrom,
                            onPicked: (d) => setState(() => dateFrom = d),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date To',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5B5B5B))),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 150,
                          child: salesFilterDateField(
                            context: context,
                            value: dateTo,
                            onPicked: (d) => setState(() => dateTo = d),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _loadInvoices,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7DD1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7)),
                      ),
                      child: const Text('Apply'),
                    ),
                    ElevatedButton(
                      onPressed: _clearFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E5E9),
                        foregroundColor: const Color(0xFF3D4147),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7)),
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
            if (_showFilters) const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0x4FFFFFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xC7FFFFFF)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 1200,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F8FA),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                                flex: 2, child: SalesHeaderText('INVOICE #')),
                            Expanded(
                                flex: 2,
                                child: SalesHeaderText('ORDER NUMBER')),
                            Expanded(
                                flex: 3,
                                child: SalesHeaderText('CUSTOMER NAME')),
                            Expanded(flex: 2, child: SalesHeaderText('STATUS')),
                            Expanded(
                                flex: 2, child: SalesHeaderText('DUE DATE')),
                            Expanded(flex: 2, child: SalesHeaderText('AMOUNT')),
                            Expanded(
                                flex: 2, child: SalesHeaderText('BALANCE DUE')),
                            Expanded(
                                flex: 1, child: SalesHeaderText('ACTIONS')),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFD9DEE5)),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_invoices.isEmpty)
                        Container(
                          width: 1200,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 24),
                          child: const Text(
                            'No invoices found. Click "+ New Invoice" to add one!',
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF42474D)),
                          ),
                        )
                      else
                        ..._invoices.map((invoice) {
                          return Column(
                            children: [
                              Container(
                                width: 1200,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 2,
                                        child: Text(invoice.invoiceNumber)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(invoice.soNumber ?? '-')),
                                    Expanded(
                                        flex: 3,
                                        child: Text(invoice.customerName)),
                                    Expanded(
                                      flex: 2,
                                      child: salesStatusPill(
                                        text: _dueStatus(invoice),
                                        bg: _dueStatusBg(invoice),
                                        fg: _dueStatusColor(invoice),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        invoice.dueDate == null
                                            ? '-'
                                            : '${invoice.dueDate!.day.toString().padLeft(2, '0')}-${invoice.dueDate!.month.toString().padLeft(2, '0')}-${invoice.dueDate!.year}',
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Text(_currency(invoice.total))),
                                    Expanded(
                                      flex: 2,
                                      child: Text(_currency(invoice.amountDue)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () =>
                                            _deleteInvoice(invoice),
                                        icon: const Icon(Icons.delete_outline,
                                            color: Color(0xFFAB2A2A), size: 20),
                                        tooltip: 'Delete invoice',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                  height: 1, color: Color(0xFFEDEFF2)),
                            ],
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceSummaryMetric extends StatelessWidget {
  const _InvoiceSummaryMetric({
    required this.label,
    required this.value,
    required this.valueColor,
    this.helperText,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0x6EFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x8FFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF536273),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (helperText != null) ...[
            const SizedBox(height: 3),
            Text(
              helperText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6D7782),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
