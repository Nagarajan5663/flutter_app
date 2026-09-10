import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../customer/customer_model.dart';
import '../../customer/customer_repository.dart';
import '../../invoices/invoice_model.dart';
import '../../invoices/invoice_repository.dart';
import '../../widgets/sales_dialog_helpers.dart';
import '../../widgets/sales_item_rows_editor.dart';
import '../delivery_challan_model.dart';
import '../delivery_challan_repository.dart';

class AddDeliveryChallanDialog extends StatefulWidget {
  const AddDeliveryChallanDialog({super.key});

  @override
  State<AddDeliveryChallanDialog> createState() => _AddDeliveryChallanDialogState();
}

class _AddDeliveryChallanDialogState extends State<AddDeliveryChallanDialog> {
  final CustomerRepository _customerRepository = InMemoryCustomerRepository();
  final InvoiceRepository _invoiceRepository = InMemoryInvoiceRepository();
  final DeliveryChallanRepository _challanRepository = InMemoryDeliveryChallanRepository();

  final challanNumberController = TextEditingController();
  final transportController = TextEditingController();

  List<CustomerModel> _customers = [];
  List<InvoiceModel> _invoices = [];
  CustomerModel? selectedCustomer;
  InvoiceModel? selectedInvoice;

  DateTime challanDate = DateTime.now();
  DateTime? deliveryDate;

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
    final invoices = await _invoiceRepository.getInvoices();
    final challanNumber = await _challanRepository.nextChallanNumber();
    if (!mounted) return;
    setState(() {
      _customers = customers;
      _invoices = invoices;
      challanNumberController.text = challanNumber;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    challanNumberController.dispose();
    transportController.dispose();
    for (final row in rows) {
      row.dispose();
    }
    super.dispose();
  }

  List<InvoiceModel> get _invoicesForSelectedCustomer {
    if (selectedCustomer == null) return _invoices;
    return _invoices.where((i) => i.customerId == selectedCustomer!.id).toList();
  }

  void _prefillFromInvoice(InvoiceModel invoice) {
    for (final row in rows) {
      row.dispose();
    }
    rows.clear();
    for (final item in invoice.items) {
      final row = SalesItemRowControllers();
      row.fillFrom(item);
      rows.add(row);
    }
    if (rows.isEmpty) rows.add(SalesItemRowControllers());
  }

  double get _subTotal => rows.fold(0.0, (sum, row) => sum + row.amount);

  void _saveChallan() {
    if (selectedCustomer == null) {
      setState(() => _errorText = 'Please select a customer');
      return;
    }
    if (challanNumberController.text.trim().isEmpty) {
      setState(() => _errorText = 'Please enter a challan number');
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

    final challan = DeliveryChallanModel(
      challanNumber: challanNumberController.text.trim(),
      customerId: selectedCustomer!.id ?? '',
      customerName: selectedCustomer!.customerName,
      invoiceId: selectedInvoice?.id,
      invoiceNumber: selectedInvoice?.invoiceNumber,
      challanDate: challanDate,
      deliveryDate: deliveryDate,
      transportationDetails: transportController.text.trim(),
      items: validItems,
    );

    Navigator.pop(context, challan);
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
                          child: Text('New Delivery Challan',
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
                                  selectedInvoice = null;
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
                            label: 'Challan # *',
                            child: salesTextField(controller: challanNumberController),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    salesLabeledField(
                      label: 'Invoice # (optional — auto-fills items)',
                      child: DropdownSearch<InvoiceModel>(
                        items: (filter, infiniteScrollProps) => _invoicesForSelectedCustomer,
                        itemAsString: (i) => i.invoiceNumber,
                        compareFn: (a, b) => a.id == b.id,
                        selectedItem: selectedInvoice,
                        onChanged: (invoice) {
                          setState(() {
                            selectedInvoice = invoice;
                            if (invoice != null) {
                              selectedCustomer ??= _customers.firstWhere(
                                (c) => c.id == invoice.customerId,
                                orElse: () => _customers.first,
                              );
                              _prefillFromInvoice(invoice);
                            }
                          });
                        },
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: salesFieldDecoration(hint: 'Select an invoice...'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: salesLabeledField(
                            label: 'Challan Date *',
                            child: salesDateField(
                              value: challanDate,
                              onTap: () => pickSalesDate(
                                context: context,
                                initial: challanDate,
                                onPicked: (d) => setState(() => challanDate = d),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: salesLabeledField(
                            label: 'Delivery Date',
                            child: salesDateField(
                              value: deliveryDate,
                              onTap: () => pickSalesDate(
                                context: context,
                                initial: deliveryDate ?? DateTime.now(),
                                onPicked: (d) => setState(() => deliveryDate = d),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    salesLabeledField(
                      label: 'Transportation Details',
                      child: salesTextField(
                        controller: transportController,
                        hint: 'e.g., Vehicle No, Transporter Name...',
                        maxLines: 2,
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
                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Sub Total: INR ${_subTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          onPressed: _isSaving ? null : _saveChallan,
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Save Challan'),
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
