import 'package:flutter/material.dart';

import '../../widgets/sales_glass_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../customer/customer_model.dart';
import '../../customer/customer_repository.dart';
import '../../invoices/invoice_model.dart';
import '../../invoices/invoice_repository.dart';
import '../../widgets/sales_dialog_helpers.dart';
import '../payment_received_model.dart';
import '../payment_received_repository.dart';

class AddPaymentReceivedDialog extends StatefulWidget {
  const AddPaymentReceivedDialog({super.key});

  @override
  State<AddPaymentReceivedDialog> createState() => _AddPaymentReceivedDialogState();
}

class _AddPaymentReceivedDialogState extends State<AddPaymentReceivedDialog> {
  final CustomerRepository _customerRepository = InMemoryCustomerRepository();
  final InvoiceRepository _invoiceRepository = InMemoryInvoiceRepository();
  final PaymentReceivedRepository _paymentRepository = InMemoryPaymentReceivedRepository();

  final paymentNumberController = TextEditingController();
  final amountController = TextEditingController();
  final utrController = TextEditingController();
  final remarksController = TextEditingController();

  List<CustomerModel> _customers = [];
  List<InvoiceModel> _invoices = [];
  CustomerModel? selectedCustomer;
  InvoiceModel? selectedInvoice;

  DateTime paymentDate = DateTime.now();

  final List<String> paymentModes = const ['Bank Transfer', 'Cash', 'Cheque', 'UPI', 'Card'];
  String paymentMode = 'Bank Transfer';

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
    final paymentNumber = await _paymentRepository.nextPaymentNumber();
    if (!mounted) return;
    setState(() {
      _customers = customers;
      _invoices = invoices;
      paymentNumberController.text = paymentNumber;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    paymentNumberController.dispose();
    amountController.dispose();
    utrController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  List<InvoiceModel> get _invoicesForSelectedCustomer {
    if (selectedCustomer == null) return [];
    return _invoices.where((i) => i.customerId == selectedCustomer!.id).toList();
  }

  void _savePayment() {
    if (selectedCustomer == null) {
      setState(() => _errorText = 'Please select a customer');
      return;
    }
    if (selectedInvoice == null) {
      setState(() => _errorText = 'Please select an invoice');
      return;
    }
    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      setState(() => _errorText = 'Please enter a valid amount received');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final payment = PaymentReceivedModel(
      paymentNumber: paymentNumberController.text.trim(),
      customerId: selectedCustomer!.id ?? '',
      customerName: selectedCustomer!.customerName,
      invoiceId: selectedInvoice!.id ?? '',
      invoiceNumber: selectedInvoice!.invoiceNumber,
      paymentDate: paymentDate,
      amountReceived: amount,
      paymentMode: paymentMode,
      utrReference: utrController.text.trim(),
      remarks: remarksController.text.trim(),
    );

    Navigator.pop(context, payment);
  }

  @override
  Widget build(BuildContext context) {
    return SalesGlassDialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 760),
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
                          child: Text('New Payment',
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
                            label: 'For Invoice *',
                            child: DropdownSearch<InvoiceModel>(
                              items: (filter, infiniteScrollProps) => _invoicesForSelectedCustomer,
                              itemAsString: (i) => i.invoiceNumber,
                              compareFn: (a, b) => a.id == b.id,
                              selectedItem: selectedInvoice,
                              enabled: selectedCustomer != null,
                              onChanged: (i) => setState(() => selectedInvoice = i),
                              popupProps: const PopupProps.menu(showSearchBox: true),
                              decoratorProps: DropDownDecoratorProps(
                                decoration: salesFieldDecoration(
                                  hint: selectedCustomer == null ? 'Select Customer First' : 'Select an invoice...',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: salesLabeledField(
                            label: 'Payment # *',
                            child: salesTextField(controller: paymentNumberController),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: salesLabeledField(
                            label: 'Payment Date *',
                            child: salesDateField(
                              value: paymentDate,
                              onTap: () => pickSalesDate(
                                context: context,
                                initial: paymentDate,
                                onPicked: (d) => setState(() => paymentDate = d),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: salesLabeledField(
                            label: 'Amount Received *',
                            child: salesTextField(
                              controller: amountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: salesLabeledField(
                            label: 'Payment Mode *',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0x6EFFFFFF),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(color: const Color(0xC7FFFFFF)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: paymentMode,
                                  isExpanded: true,
                                  items: paymentModes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => paymentMode = value);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    salesLabeledField(
                      label: 'UTR Details / Reference #',
                      child: salesTextField(controller: utrController),
                    ),
                    const SizedBox(height: 18),

                    salesLabeledField(
                      label: 'Remarks',
                      child: salesTextField(controller: remarksController, maxLines: 3),
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
                          onPressed: _isSaving ? null : _savePayment,
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Save Payment'),
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
