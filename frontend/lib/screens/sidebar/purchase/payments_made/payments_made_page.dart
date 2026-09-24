import 'package:flutter/material.dart';

import '../shared/glass_modal_shell.dart';

class _PaymentMade {
  final String vendor;
  final String billNumber;
  final double amount;
  final DateTime date;
  final String mode;

  const _PaymentMade({
    required this.vendor,
    required this.billNumber,
    required this.amount,
    required this.date,
    required this.mode,
  });
}

class PaymentsMadePage extends StatefulWidget {
  const PaymentsMadePage({super.key});

  @override
  State<PaymentsMadePage> createState() => _PaymentsMadePageState();
}

class _PaymentsMadePageState extends State<PaymentsMadePage> {
  final List<_PaymentMade> _payments = [
    _PaymentMade(
      vendor: 'Acme Supplies',
      billNumber: 'BILL-1001',
      amount: 1250,
      date: DateTime(2026, 8, 28),
      mode: 'Bank Transfer',
    ),
  ];

  String _search = '';

  List<_PaymentMade> get _filteredPayments {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return _payments;
    return _payments
        .where((payment) =>
            payment.vendor.toLowerCase().contains(query) ||
            payment.billNumber.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _recordPayment() async {
    final payment = await showDialog<_PaymentMade>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _RecordPaymentDialog(),
    );

    if (!mounted || payment == null) return;
    setState(() => _payments.insert(0, payment));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment recorded successfully')),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  @override
  Widget build(BuildContext context) {
    final payments = _filteredPayments;
    final total = _payments.fold<double>(0, (sum, payment) => sum + payment.amount);

    return GlassPageBackground(
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
                GlassButton(
                  onPressed: _recordPayment,
                  icon: Icons.add,
                  label: 'Record Payment',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _summaryCard('Total Payments', '${_payments.length}', Icons.receipt_long_outlined),
                _summaryCard('Total Amount', '₹${total.toStringAsFixed(2)}', Icons.payments_outlined),
              ],
            ),
            const SizedBox(height: 20),
            GlassPanel(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) => setState(() => _search = value),
                decoration: const InputDecoration(
                  labelText: 'Search vendor or bill number',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GlassPanel(
              padding: EdgeInsets.zero,
              child: payments.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: Text('No payments found')),
                    )
                  : Column(
                      children: [
                        for (final payment in payments)
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE4F2EA),
                              child: Icon(Icons.check, color: Color(0xFF1E7B34)),
                            ),
                            title: Text(
                              payment.vendor,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '${payment.billNumber}  •  ${_formatDate(payment.date)}  •  ${payment.mode}',
                            ),
                            trailing: Text(
                              '₹${payment.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF123456),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return SizedBox(
      width: 220,
      child: GlassPanel(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2D7FF9), size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF718391))),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordPaymentDialog extends StatefulWidget {
  const _RecordPaymentDialog();

  @override
  State<_RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<_RecordPaymentDialog> {
  final vendorController = TextEditingController();
  final billController = TextEditingController();
  final amountController = TextEditingController();
  String mode = 'Bank Transfer';
  String? errorText;

  @override
  void dispose() {
    vendorController.dispose();
    billController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(amountController.text.trim());
    if (vendorController.text.trim().isEmpty || billController.text.trim().isEmpty) {
      setState(() => errorText = 'Please enter the vendor and bill number');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => errorText = 'Please enter a valid payment amount');
      return;
    }
    Navigator.pop(
      context,
      _PaymentMade(
        vendor: vendorController.text.trim(),
        billNumber: billController.text.trim(),
        amount: amount,
        date: DateTime.now(),
        mode: mode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassModalShell(
      maxWidth: 600,
      maxHeight: 620,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(34, 30, 34, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassDialogHeader(
              title: 'Record Payment',
              icon: Icons.payments_outlined,
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
            if (errorText != null) ...[
              Text(errorText!, style: const TextStyle(color: Color(0xFFAB2A2A))),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: vendorController,
              decoration: const InputDecoration(labelText: 'Vendor *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: billController,
              decoration: const InputDecoration(labelText: 'Bill number *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount *', prefixText: '₹ ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: mode,
              decoration: const InputDecoration(labelText: 'Payment mode', border: OutlineInputBorder()),
              items: const ['Bank Transfer', 'Cash', 'Cheque', 'Credit Card']
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => mode = value!),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: GlassButton(
                onPressed: _save,
                icon: Icons.check,
                label: 'Save Payment',
              ),
            ),
          ],
        ),
      ),
    );
  }
}