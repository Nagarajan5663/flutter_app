import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../customer/customer_model.dart';
import '../../customer/customer_repository.dart';
import '../../sales_orders/sales_order_model.dart';
import '../../sales_orders/sales_order_repository.dart';
import '../../widgets/sales_dialog_helpers.dart';
import '../../widgets/sales_item_rows_editor.dart';
import '../invoice_model.dart';
import '../invoice_repository.dart';

class AddInvoiceDialog extends StatefulWidget {
  const AddInvoiceDialog({super.key});

  @override
  State<AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends State<AddInvoiceDialog> {
  final CustomerRepository _customerRepository = InMemoryCustomerRepository();
  final SalesOrderRepository _orderRepository = InMemorySalesOrderRepository();
  final InvoiceRepository _invoiceRepository = InMemoryInvoiceRepository();

  final invoiceNumberController = TextEditingController();
  final taxController = TextEditingController(text: '0.00');

  List<CustomerModel> _customers = [];
  List<SalesOrderModel> _orders = [];
  CustomerModel? selectedCustomer;
  SalesOrderModel? selectedOrder;

  DateTime date = DateTime.now();
  DateTime? dueDate;

  final List<String> creditTermsOptions = const [
    'Immediate Payment',
    'Due on Receipt',
    'Net 15',
    'Net 30',
    'Net 45',
  ];
  String creditTerms = 'Immediate Payment';

  final List<SalesItemRowControllers> rows = [SalesItemRowControllers()];

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final customers = await _customerRepository.getCustomers();
    final orders = await _orderRepository.getSalesOrders();
    final invoiceNumber = await _invoiceRepository.nextInvoiceNumber();
    if (!mounted) return;
    setState(() {
      _customers = customers;
      _orders = orders;
      invoiceNumberController.text = invoiceNumber;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    invoiceNumberController.dispose();
    taxController.dispose();
    for (final row in rows) {
      row.dispose();
    }
    super.dispose();
  }

  List<SalesOrderModel> get _ordersForSelectedCustomer {
    if (selectedCustomer == null) return _orders;
    return _orders.where((o) => o.customerId == selectedCustomer!.id).toList();
  }

  void _prefillFromOrder(SalesOrderModel order) {
    for (final row in rows) {
      row.dispose();
    }
    rows.clear();
    for (final item in order.items) {
      final row = SalesItemRowControllers();
      row.fillFrom(item);
      rows.add(row);
    }
    if (rows.isEmpty) rows.add(SalesItemRowControllers());
  }

  double get _subTotal => rows.fold(0.0, (sum, row) => sum + row.amount);
  double get _tax => double.tryParse(taxController.text) ?? 0;
  double get _total => _subTotal + _tax;

  void _saveInvoice() {
    if (selectedCustomer == null) {
      setState(() => _errorText = 'Please select a customer');
      return;
    }
    if (invoiceNumberController.text.trim().isEmpty) {
      setState(() => _errorText = 'Please enter an invoice number');
      return;
    }

    final validItems = rows.map((r) => r.toModelOrNull()).where((i) => i != null).map((i) => i!).toList();
    if (validItems.isEmpty) {
      setState(() => _errorText = 'Please add at least one item');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final invoice = InvoiceModel(
      invoiceNumber: invoiceNumberController.text.trim(),
      soId: selectedOrder?.id,
      soNumber: selectedOrder?.soNumber,
      customerId: selectedCustomer!.id ?? '',
      customerName: selectedCustomer!.customerName,
      date: date,
      dueDate: dueDate,
      creditTerms: creditTerms,
      items: validItems,
      tax: _tax,
    );

    Navigator.pop(context, invoice);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 820),
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(60),
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(34, 30, 34, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('New Invoice',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF123456))),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Color(0xFFAAAAAA), size: 25),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (_errorText != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration:
                            BoxDecoration(color: const Color(0xFFF4E3E3), borderRadius: BorderRadius.circular(7)),
                        child: Text(_errorText!, style: const TextStyle(color: Color(0xFFAB2A2A))),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: salesLabeledField(
                            label: 'Customer Name *',
                            child: DropdownSearch<CustomerModel>(
                              items: (filter, infiniteScrollProps) => _customers,
                              itemAsString: (c) => c.customerName,
                              compareFn: (a, b) => a.id == b.id,
                              selectedItem: selectedCustomer,
                              onChanged: (c) {
                                setState(() {
                                  selectedCustomer = c;
                                  selectedOrder = null;
                                });
                              },
                              popupProps: const PopupProps.menu(showSearchBox: true),
                              decoratorProps: DropDownDecoratorProps(
                                decoration: salesFieldDecoration(hint: 'Select or type to search...'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: salesLabeledField(
                            label: 'Invoice # *',
                            child: salesTextField(controller: invoiceNumberController),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    salesLabeledField(
                      label: 'Sales Order # (optional — auto-fills items)',
                      child: DropdownSearch<SalesOrderModel>(
                        items: (filter, infiniteScrollProps) => _ordersForSelectedCustomer,
                        itemAsString: (o) => o.soNumber,
                        compareFn: (a, b) => a.id == b.id,
                        selectedItem: selectedOrder,
                        onChanged: (order) {
                          setState(() {
                            selectedOrder = order;
                            if (order != null) {
                              selectedCustomer ??= _customers.firstWhere(
                                (c) => c.id == order.customerId,
                                orElse: () => _customers.first,
                              );
                              _prefillFromOrder(order);
                            }
                          });
                        },
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: salesFieldDecoration(hint: 'Select a sales order...'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: salesLabeledField(
                            label: 'Date *',
                            child: salesDateField(
                              value: date,
                              onTap: () => pickSalesDate(
                                context: context,
                                initial: date,
                                onPicked: (d) => setState(() => date = d),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: salesLabeledField(
                            label: 'Due Date',
                            child: salesDateField(
                              value: dueDate,
                              onTap: () => pickSalesDate(
                                context: context,
                                initial: dueDate ?? DateTime.now(),
                                onPicked: (d) => setState(() => dueDate = d),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    salesLabeledField(
                      label: 'Credit Terms',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: const Color(0xFFD9DEE5)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: creditTerms,
                            isExpanded: true,
                            style: const TextStyle(color: Colors.black),
                            items: creditTermsOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => creditTerms = value);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SalesItemRowsEditor(
                      rows: rows,
                      onAddRow: () => setState(() => rows.add(SalesItemRowControllers())),
                      onRemoveRow: (index) {
                        if (rows.length == 1) return;
                        setState(() {
                          rows[index].dispose();
                          rows.removeAt(index);
                        });
                      },
                      onRowChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Sub Total: INR ${_subTotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Tax: INR '),
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  controller: taxController,
                                  style: const TextStyle(color: Colors.black),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.right,
                                  onChanged: (_) => setState(() {}),
                                  decoration: salesFieldDecoration(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Total: INR ${_total.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C757D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveInvoice,
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Save Invoice'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF123456),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
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
