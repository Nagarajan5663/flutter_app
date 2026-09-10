import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../bills/bill_model.dart';
import '../../bills/bill_repository.dart';
import '../payment_model.dart';
import '../payment_repository.dart';

class RecordPaymentDialog extends StatefulWidget {
  const RecordPaymentDialog({super.key});

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final BillRepository _billRepository = InMemoryBillRepository();
  final PaymentRepository _paymentRepository = InMemoryPaymentRepository();

  final amountPaidController = TextEditingController();
  final referenceController = TextEditingController();

  List<BillModel> _unpaidBills = [];
  BillModel? selectedBill;

  DateTime paymentDate = DateTime.now();

  final List<String> paymentModeOptions = const [
    'Bank Transfer',
    'Cash',
    'Cheque',
    'Credit Card',
    'UPI',
    'Other',
  ];
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
    final bills = await _billRepository.getBills();

    if (!mounted) return;
    setState(() {
      _unpaidBills = bills.where((b) => b.amountDue > 0).toList();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    amountPaidController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => paymentDate = picked);
  }

  Future<void> _savePayment() async {
    if (selectedBill == null) {
      setState(() => _errorText = 'Please select a bill');
      return;
    }
    final amountPaid = double.tryParse(amountPaidController.text) ?? 0;
    if (amountPaid <= 0) {
      setState(() => _errorText = 'Please enter a valid amount paid');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final paymentNumber = await _paymentRepository.nextPaymentNumber();

    final payment = PaymentModel(
      paymentNumber: paymentNumber,
      billId: selectedBill!.id ?? '',
      billNumber: selectedBill!.billNumber,
      vendorId: selectedBill!.vendorId,
      vendorName: selectedBill!.vendorName,
      amountDue: selectedBill!.amountDue,
      paymentDate: paymentDate,
      amountPaid: amountPaid,
      paymentMode: paymentMode,
      referenceNumber: referenceController.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context, payment);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 640),
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
                          child: Text(
                            'Record Payment',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF123456),
                            ),
                          ),
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
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4E3E3),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          _errorText!,
                          style: const TextStyle(color: Color(0xFFAB2A2A)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    _labeledField(
                      label: 'Bill # *',
                      child: DropdownSearch<BillModel>(
                        items: (filter, infiniteScrollProps) => _unpaidBills,
                        itemAsString: (b) => b.billNumber,
                        compareFn: (a, b) => a.id == b.id,
                        selectedItem: selectedBill,
                        onChanged: (b) => setState(() => selectedBill = b),
                        popupProps: const PopupProps.menu(showSearchBox: true),
                        decoratorProps: DropDownDecoratorProps(
                          decoration: _fieldDecoration(hint: '--- Select a Bill ---'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _labeledField(
                            label: 'Vendor',
                            child: _readOnlyField(selectedBill?.vendorName ?? ''),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _labeledField(
                            label: 'Amount Due',
                            child: _readOnlyField(
                              selectedBill == null
                                  ? ''
                                  : 'INR ${selectedBill!.amountDue.toStringAsFixed(2)}',
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
                          child: _labeledField(
                            label: 'Payment Date *',
                            child: _dateField(value: paymentDate, onTap: _pickDate),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _labeledField(
                            label: 'Amount Paid *',
                            child: _textField(
                              controller: amountPaidController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                          child: _labeledField(
                            label: 'Payment Mode *',
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: const Color(0xFFD9DEE5)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: paymentMode,
                                  style: const TextStyle(color: Colors.black),
                                  isExpanded: true,
                                  items: paymentModeOptions
                                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => paymentMode = value);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _labeledField(
                            label: 'Reference #',
                            child: _textField(
                              controller: referenceController,
                              hint: 'e.g., Cheque or TXN ID',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE2E5E9),
                            foregroundColor: const Color(0xFF3D4147),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _savePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7DD1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                          ),
                          child: const Text('Save Payment'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3D4147),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFF123456), width: 2),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      keyboardType: keyboardType,
      decoration: _fieldDecoration(hint: hint),
    );
  }

  Widget _readOnlyField(String value) {
    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F4),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFD9DEE5)),
      ),
      child: Text(value, style: const TextStyle(color: Color(0xFF3D4147))),
    );
  }

  Widget _dateField({required DateTime? value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                style: const TextStyle(color: Colors.black),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF888888)),
          ],
        ),
      ),
    );
  }
}
