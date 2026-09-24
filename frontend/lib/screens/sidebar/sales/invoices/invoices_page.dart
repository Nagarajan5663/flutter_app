import 'package:flutter/material.dart';

import '../widgets/sales_glass_widgets.dart';

import '../widgets/sales_dialog_helpers.dart';
import 'invoice_filter.dart';
import 'invoice_model.dart';
import 'invoice_repository.dart';
import 'widgets/add_invoice_dialog.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final InvoiceRepository _repository = InMemoryInvoiceRepository();

  List<InvoiceModel> _invoices = [];
  bool _isLoading = true;

  final customerController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;

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
    final result = await _repository.getInvoices(filter: _currentFilter);
    if (!mounted) return;
    setState(() {
      _invoices = result;
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice created successfully')));
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

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF1E7B34);
      case 'Partially Paid':
        return const Color(0xFFB8860B);
      default:
        return const Color(0xFFAB2A2A);
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFFE3F6E8);
      case 'Partially Paid':
        return const Color(0xFFFFF3D6);
      default:
        return const Color(0xFFF4E3E3);
    }
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
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF123456))),
                ),
                ElevatedButton.icon(
                  onPressed: _openAddInvoice,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF123456),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

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
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
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
                            items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
                      const SizedBox(height: 6),
                      SizedBox(width: 180, child: salesFilterTextField(customerController, 'Customer name...')),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date From',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
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
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
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
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    ),
                    child: const Text('Filter'),
                  ),
                  ElevatedButton(
                    onPressed: _clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE2E5E9),
                      foregroundColor: const Color(0xFF3D4147),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    ),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                  width: 1050,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 1050,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: SalesHeaderText('DATE')),
                            Expanded(flex: 2, child: SalesHeaderText('INVOICE #')),
                            Expanded(flex: 2, child: SalesHeaderText('SO #')),
                            Expanded(flex: 3, child: SalesHeaderText('CUSTOMER NAME')),
                            Expanded(flex: 2, child: SalesHeaderText('DUE DATE')),
                            Expanded(flex: 2, child: SalesHeaderText('STATUS')),
                            Expanded(flex: 2, child: SalesHeaderText('AMOUNT')),
                            Expanded(flex: 1, child: SalesHeaderText('ACTIONS')),
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
                          width: 1050,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                          child: const Text(
                            'No invoices found. Click "+ New Invoice" to add one!',
                            style: TextStyle(fontSize: 16, color: Color(0xFF42474D)),
                          ),
                        )
                      else
                        ..._invoices.map((invoice) {
                          return Column(
                            children: [
                              Container(
                                width: 1050,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                          '${invoice.date.day.toString().padLeft(2, '0')}-${invoice.date.month.toString().padLeft(2, '0')}-${invoice.date.year}'),
                                    ),
                                    Expanded(flex: 2, child: Text(invoice.invoiceNumber)),
                                    Expanded(flex: 2, child: Text(invoice.soNumber ?? '-')),
                                    Expanded(flex: 3, child: Text(invoice.customerName)),
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
                                      child: salesStatusPill(
                                        text: invoice.status,
                                        bg: _statusBg(invoice.status),
                                        fg: _statusColor(invoice.status),
                                      ),
                                    ),
                                    Expanded(flex: 2, child: Text('INR ${invoice.total.toStringAsFixed(2)}')),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () => _deleteInvoice(invoice),
                                        icon: const Icon(Icons.delete_outline, color: Color(0xFFAB2A2A), size: 20),
                                        tooltip: 'Delete invoice',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Color(0xFFEDEFF2)),
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