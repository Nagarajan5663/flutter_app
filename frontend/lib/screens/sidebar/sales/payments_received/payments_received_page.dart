import 'package:flutter/material.dart';

import '../widgets/sales_glass_widgets.dart';

import '../widgets/sales_dialog_helpers.dart';
import 'payment_received_filter.dart';
import 'payment_received_model.dart';
import 'payment_received_repository.dart';
import 'widgets/add_payment_received_dialog.dart';

class PaymentsReceivedPage extends StatefulWidget {
  const PaymentsReceivedPage({super.key});

  @override
  State<PaymentsReceivedPage> createState() => _PaymentsReceivedPageState();
}

class _PaymentsReceivedPageState extends State<PaymentsReceivedPage> {
  final PaymentReceivedRepository _repository = InMemoryPaymentReceivedRepository();

  List<PaymentReceivedModel> _payments = [];
  bool _isLoading = true;

  final customerController = TextEditingController();
  final invoiceController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    customerController.dispose();
    invoiceController.dispose();
    super.dispose();
  }

  PaymentReceivedFilter get _currentFilter => PaymentReceivedFilter(
        customerName: customerController.text,
        invoiceNumber: invoiceController.text,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    final result = await _repository.getPayments(filter: _currentFilter);
    if (!mounted) return;
    setState(() {
      _payments = result;
      _isLoading = false;
    });
  }

  Future<void> _openAddPayment() async {
    final payment = await showDialog<PaymentReceivedModel>(
      context: context,
      barrierColor: const Color(0x9A12202C),
      barrierDismissible: false,
      builder: (_) => const AddPaymentReceivedDialog(),
    );
    if (!mounted || payment == null) return;
    await _repository.addPayment(payment);
    await _loadPayments();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment recorded successfully')));
  }

  Future<void> _deletePayment(PaymentReceivedModel payment) async {
    if (payment.id == null) return;
    await _repository.deletePayment(payment.id!);
    await _loadPayments();
  }

  void _clearFilters() {
    customerController.clear();
    invoiceController.clear();
    dateFrom = null;
    dateTo = null;
    _loadPayments();
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
                  child: Text('Payments Received',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF123456))),
                ),
                ElevatedButton.icon(
                  onPressed: _openAddPayment,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Payment'),
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
                      const Text('Customer Name',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
                      const SizedBox(height: 6),
                      SizedBox(width: 170, child: salesFilterTextField(customerController, 'Customer name...')),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoice #',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
                      const SizedBox(height: 6),
                      SizedBox(width: 150, child: salesFilterTextField(invoiceController, 'Invoice number...')),
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
                    onPressed: _loadPayments,
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
                  width: 1100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 1100,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: SalesHeaderText('PAYMENT DATE')),
                            Expanded(flex: 2, child: SalesHeaderText('PAYMENT #')),
                            Expanded(flex: 2, child: SalesHeaderText('INVOICE #')),
                            Expanded(flex: 2, child: SalesHeaderText('CUSTOMER NAME')),
                            Expanded(flex: 2, child: SalesHeaderText('MODE')),
                            Expanded(flex: 2, child: SalesHeaderText('AMOUNT RECEIVED')),
                            Expanded(flex: 2, child: SalesHeaderText('UTR/REFERENCE')),
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
                      else if (_payments.isEmpty)
                        Container(
                          width: 1100,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                          child: const Text(
                            'No payments received yet. Click "+ New Payment" to add one!',
                            style: TextStyle(fontSize: 16, color: Color(0xFF42474D)),
                          ),
                        )
                      else
                        ..._payments.map((payment) {
                          return Column(
                            children: [
                              Container(
                                width: 1100,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                          '${payment.paymentDate.day.toString().padLeft(2, '0')}-${payment.paymentDate.month.toString().padLeft(2, '0')}-${payment.paymentDate.year}'),
                                    ),
                                    Expanded(flex: 2, child: Text(payment.paymentNumber)),
                                    Expanded(flex: 2, child: Text(payment.invoiceNumber)),
                                    Expanded(flex: 2, child: Text(payment.customerName)),
                                    Expanded(flex: 2, child: Text(payment.paymentMode)),
                                    Expanded(flex: 2, child: Text('INR ${payment.amountReceived.toStringAsFixed(2)}')),
                                    Expanded(flex: 2, child: Text(payment.utrReference.isEmpty ? '-' : payment.utrReference)),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () => _deletePayment(payment),
                                        icon: const Icon(Icons.delete_outline, color: Color(0xFFAB2A2A), size: 20),
                                        tooltip: 'Delete payment',
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