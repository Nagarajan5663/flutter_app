import 'package:flutter/material.dart';

import '../bills/bill_repository.dart';
import 'payment_filter.dart';
import 'payment_model.dart';
import 'payment_repository.dart';
import 'widgets/record_payment_dialog.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final PaymentRepository _repository = InMemoryPaymentRepository();
  final BillRepository _billRepository = InMemoryBillRepository();

  List<PaymentModel> _payments = [];
  bool _isLoading = true;

  final vendorController = TextEditingController();
  final billController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    vendorController.dispose();
    billController.dispose();
    super.dispose();
  }

  PaymentFilter get _currentFilter => PaymentFilter(
        vendorName: vendorController.text,
        billNumber: billController.text,
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

  Future<void> _openRecordPayment() async {
    final payment = await showDialog<PaymentModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RecordPaymentDialog(),
    );

    if (!mounted || payment == null) return;

    // Save the payment, then apply it against the bill's amount due/status.
    await _repository.addPayment(payment);
    await _billRepository.recordPayment(payment.billId, payment.amountPaid);
    await _loadPayments();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment recorded successfully')),
    );
  }

  Future<void> _deletePayment(PaymentModel payment) async {
    if (payment.id == null) return;
    await _repository.deletePayment(payment.id!);
    await _loadPayments();
  }

  void _clearFilters() {
    vendorController.clear();
    billController.clear();
    dateFrom = null;
    dateTo = null;
    _loadPayments();
  }

  Future<void> _pickDate(DateTime? initial, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  String _fmt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFF4F6F9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Payments Made',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF123456),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openRecordPayment,
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

            // FILTER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD9DEE5)),
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  _filterField(
                    label: 'Vendor Name',
                    child: SizedBox(
                        width: 180, child: _filterTextField(vendorController, 'Vendor name...')),
                  ),
                  _filterField(
                    label: 'Bill #',
                    child: SizedBox(
                        width: 160, child: _filterTextField(billController, 'Bill number...')),
                  ),
                  _filterField(
                    label: 'Date From',
                    child: SizedBox(
                      width: 160,
                      child: _filterDateField(dateFrom, (d) => setState(() => dateFrom = d)),
                    ),
                  ),
                  _filterField(
                    label: 'Date To',
                    child: SizedBox(
                      width: 160,
                      child: _filterDateField(dateTo, (d) => setState(() => dateTo = d)),
                    ),
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

            // TABLE CARD
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD9DEE5)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 950,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 950,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: _HeaderText('DATE')),
                            Expanded(flex: 2, child: _HeaderText('PAYMENT #')),
                            Expanded(flex: 2, child: _HeaderText('BILL #')),
                            Expanded(flex: 3, child: _HeaderText('VENDOR NAME')),
                            Expanded(flex: 2, child: _HeaderText('MODE')),
                            Expanded(flex: 2, child: _HeaderText('AMOUNT')),
                            Expanded(flex: 1, child: _HeaderText('ACTIONS')),
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
                          width: 950,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                          child: const Text(
                            'No payments found. Click "+ New Payment" to add one!',
                            style: TextStyle(fontSize: 16, color: Color(0xFF42474D)),
                          ),
                        )
                      else
                        ..._payments.map((payment) {
                          return Column(
                            children: [
                              Container(
                                width: 950,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(flex: 2, child: Text(_fmt(payment.paymentDate))),
                                    Expanded(flex: 2, child: Text(payment.paymentNumber)),
                                    Expanded(flex: 2, child: Text(payment.billNumber)),
                                    Expanded(flex: 3, child: Text(payment.vendorName)),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE7EEF6),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            payment.paymentMode,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF123456),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child:
                                            Text('INR ${payment.amountPaid.toStringAsFixed(2)}')),
                                    Expanded(
                                      flex: 1,
                                      child: IconButton(
                                        onPressed: () => _deletePayment(payment),
                                        icon: const Icon(Icons.delete_outline,
                                            color: Color(0xFFAB2A2A), size: 20),
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

  Widget _filterField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5B5B5B))),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _filterTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFF123456), width: 2),
        ),
      ),
    );
  }

  Widget _filterDateField(DateTime? value, ValueChanged<DateTime> onPicked) {
    return GestureDetector(
      onTap: () => _pickDate(value, onPicked),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFFD9DEE5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? 'dd-mm-yyyy'
                    : '${value.day.toString().padLeft(2, '0')}-${value.month.toString().padLeft(2, '0')}-${value.year}',
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF888888)),
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  const _HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF5B5B5B)),
    );
  }
}