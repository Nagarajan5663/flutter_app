import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/pdf_file_download.dart';
import '../bills/bill_model.dart';
import '../bills/bill_repository.dart';
import '../shared/glass_modal_shell.dart';
import 'payment_made_model.dart';
import 'payment_made_repository.dart';

class PaymentsMadePage extends StatefulWidget {
  const PaymentsMadePage({super.key});

  @override
  State<PaymentsMadePage> createState() => _PaymentsMadePageState();
}

class _PaymentsMadePageState extends State<PaymentsMadePage> {
  final _paymentRepository = PaymentMadeRepository();
  final BillRepository _billRepository = InMemoryBillRepository();
  final _vendorController = TextEditingController();
  final _billController = TextEditingController();

  List<PaymentMadeModel> _payments = [];
  List<BillModel> _bills = [];
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _billController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _paymentRepository.getPayments(
          vendor: _vendorController.text,
          billNumber: _billController.text,
          dateFrom: _dateFrom,
          dateTo: _dateTo,
        ),
        _billRepository.getBills(),
      ]);
      if (!mounted) return;
      setState(() {
        _payments = results[0] as List<PaymentMadeModel>;
        _bills = results[1] as List<BillModel>;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _newPayment() async {
    final details = await showDialog<_PaymentFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentFormDialog(bills: _bills),
    );
    if (!mounted || details == null) return;

    try {
      await _billRepository.recordPayment(
        details.bill.id!,
        details.amount,
        details.date,
        details.mode,
        details.reference,
        details.paidBy,
        details.notes,
      );
      await _loadData();
      if (!mounted) return;
      _showMessage('Payment recorded successfully');
    } catch (error) {
      if (mounted) _showMessage('Unable to record payment: $error', error: true);
    }
  }

  Future<void> _editPayment(PaymentMadeModel payment) async {
    final bill = _bills.where((item) => item.id == payment.billId).firstOrNull;
    if (bill == null) {
      _showMessage('The bill for this payment could not be found', error: true);
      return;
    }
    if (bill.isVoided) {
      _showMessage('Payments for voided bills cannot be edited', error: true);
      return;
    }
    final details = await showDialog<_PaymentFormResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PaymentFormDialog(
        bills: _bills,
        initialBill: bill,
        payment: payment,
      ),
    );
    if (!mounted || details == null) return;
    try {
      await _paymentRepository.updatePayment(
        PaymentMadeModel(
          id: payment.id,
          paymentNumber: payment.paymentNumber,
          billId: payment.billId,
          billNumber: payment.billNumber,
          vendorName: payment.vendorName,
          vendorInvoiceNumber: payment.vendorInvoiceNumber,
          date: details.date,
          amount: details.amount,
          mode: details.mode,
          reference: details.reference,
          paidBy: details.paidBy,
          notes: details.notes,
        ),
      );
      await _loadData();
      if (mounted) _showMessage('Payment updated successfully');
    } catch (error) {
      if (mounted) _showMessage('Unable to update payment: $error', error: true);
    }
  }

  Future<void> _deletePayment(PaymentMadeModel payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text('Delete ${payment.paymentNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _paymentRepository.deletePayment(payment.id);
      await _loadData();
      if (mounted) _showMessage('Payment deleted successfully');
    } catch (error) {
      if (mounted) _showMessage('Unable to delete payment: $error', error: true);
    }
  }

  Future<void> _showPayment(PaymentMadeModel payment) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (_) => _PaymentDetailDialog(
        payment: payment,
        onDownload: () => _downloadPayment(payment),
        onSendMail: () => _sendMail(payment),
        onSendWhatsApp: () => _sendWhatsApp(payment),
      ),
    );
  }

  Future<void> _downloadPayment(PaymentMadeModel payment) async {
    final pdf = pw.Document();
    final currency = NumberFormat('#,##0.00', 'en_IN');
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(38),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              payment.vendorName,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              '${payment.paymentNumber} | ${_formatDate(payment.date)}',
            ),
            pw.SizedBox(height: 36),
            pw.Text('Amount Paid', style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 6),
            pw.Text(
              'INR ${currency.format(payment.amount)}',
              style: pw.TextStyle(
                fontSize: 23,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Divider(),
            pw.SizedBox(height: 12),
            _pdfLine('Paid By', _display(payment.paidBy)),
            _pdfLine('Bill Paid', payment.billNumber),
            _pdfLine(
              'Vendor Invoice #',
              _display(payment.vendorInvoiceNumber),
            ),
            _pdfLine('Payment Mode', payment.mode),
            _pdfLine('Reference #', _display(payment.reference)),
            _pdfLine('Notes', _display(payment.notes)),
          ],
        ),
      ),
    );

    try {
      final safeNumber =
          payment.paymentNumber.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '-');
      final downloaded = await downloadPdfFile(
        await pdf.save(),
        'payment-$safeNumber.pdf',
      );
      if (mounted) {
        _showMessage(
          downloaded ? 'Payment PDF downloaded' : 'PDF download cancelled',
        );
      }
    } catch (error) {
      if (mounted) _showMessage('Unable to download PDF: $error', error: true);
    }
  }

  Future<void> _sendMail(PaymentMadeModel payment) async {
    final recipient = payment.vendorEmail.trim();
    if (recipient.isEmpty || !recipient.contains('@')) {
      if (mounted) {
        _showMessage(
          'Add a valid email address to this vendor before sending.',
          error: true,
        );
      }
      return;
    }
    final uri = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: {
        'subject': 'Payment ${payment.paymentNumber}',
        'body': 'Payment of INR ${payment.amount.toStringAsFixed(2)} '
            'for bill ${payment.billNumber} from ${payment.vendorName}.',
      },
    );
    try {
      if (!await launchUrl(uri)) {
        throw Exception('No email app is available');
      }
    } catch (error) {
      if (mounted) _showMessage('Unable to open email: $error', error: true);
    }
  }

  Future<void> _sendWhatsApp(PaymentMadeModel payment) async {
    final phone = payment.vendorPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.length < 7) {
      if (mounted) {
        _showMessage(
          'Add a valid phone number to this vendor before sending.',
          error: true,
        );
      }
      return;
    }
    final uri = Uri.https('wa.me', '/$phone', {
      'text': 'Payment ${payment.paymentNumber} of '
          'INR ${payment.amount.toStringAsFixed(2)} for bill '
          '${payment.billNumber} from ${payment.vendorName}.',
    });
    try {
      if (!await launchUrl(uri)) {
        throw Exception('No app is available to open WhatsApp');
      }
    } catch (error) {
      if (mounted) _showMessage('Unable to open WhatsApp: $error', error: true);
    }
  }

  pw.Widget _pdfLine(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 7),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [pw.Text(label), pw.Text(value)],
        ),
      );

  Future<void> _pickDate(
    DateTime? current,
    ValueChanged<DateTime> onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => onPicked(picked));
  }

  void _clearFilters() {
    _vendorController.clear();
    _billController.clear();
    setState(() {
      _dateFrom = null;
      _dateTo = null;
    });
    _loadData();
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFAB2A2A) : null,
      ),
    );
  }

  String _formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  String _display(String value) => value.trim().isEmpty ? 'N/A' : value;

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _newPayment,
                  icon: Icons.add,
                  label: 'New Payment',
                ),
              ],
            ),
            const SizedBox(height: 20),
            GlassPanel(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  _filterField(
                    'Vendor Name',
                    SizedBox(
                      width: 185,
                      child: _filterTextField(
                        _vendorController,
                        'Vendor name...',
                      ),
                    ),
                  ),
                  _filterField(
                    'Bill #',
                    SizedBox(
                      width: 185,
                      child: _filterTextField(
                        _billController,
                        'Bill number...',
                      ),
                    ),
                  ),
                  _filterField(
                    'Date From',
                    SizedBox(
                      width: 155,
                      child: _dateField(
                        _dateFrom,
                        (date) => _dateFrom = date,
                      ),
                    ),
                  ),
                  _filterField(
                    'Date To',
                    SizedBox(
                      width: 155,
                      child: _dateField(
                        _dateTo,
                        (date) => _dateTo = date,
                      ),
                    ),
                  ),
                  GlassButton(
                    onPressed: _loadData,
                    icon: Icons.filter_alt_outlined,
                    label: 'Filter',
                  ),
                  GlassButton(
                    onPressed: _clearFilters,
                    icon: Icons.clear,
                    label: 'Clear',
                    primary: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassPanel(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Show:'),
                      const SizedBox(width: 10),
                      DropdownButton<int>(
                        value: 25,
                        items: const [25, 50, 100]
                            .map(
                              (size) => DropdownMenuItem(
                                value: size,
                                child: Text('$size'),
                              ),
                            )
                            .toList(),
                        onChanged: (_) {},
                      ),
                      const Spacer(),
                      const Text('Page 1 of 1'),
                      const SizedBox(width: 12),
                      _pageButton('‹ Prev', enabled: false),
                      const SizedBox(width: 8),
                      _pageButton('Next ›', enabled: false),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          TextButton(
                            onPressed: _loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.sizeOf(context).width - 340,
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            const Color(0xFFF5F6F7),
                          ),
                          columns: const [
                            DataColumn(label: Text('DATE')),
                            DataColumn(label: Text('PAYMENT #')),
                            DataColumn(label: Text('BILL #')),
                            DataColumn(label: Text('VENDOR NAME')),
                            DataColumn(label: Text('MODE')),
                            DataColumn(label: Text('AMOUNT')),
                            DataColumn(label: Text('ACTIONS')),
                          ],
                          rows: _payments
                              .map(
                                (payment) => DataRow(
                                  cells: [
                                    DataCell(Text(_formatDate(payment.date))),
                                    DataCell(Text(payment.paymentNumber)),
                                    DataCell(Text(payment.billNumber)),
                                    DataCell(Text(payment.vendorName)),
                                    DataCell(Text(payment.mode)),
                                    DataCell(
                                      Text(
                                        'INR${payment.amount.toStringAsFixed(2)}',
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _action(
                                            Icons.visibility_outlined,
                                            'View payment',
                                            () => _showPayment(payment),
                                          ),
                                          _action(
                                            Icons.edit_outlined,
                                            'Edit payment',
                                            () => _editPayment(payment),
                                          ),
                                          _action(
                                            Icons.delete_outline,
                                            'Delete payment',
                                            () => _deletePayment(payment),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  if (!_isLoading && _error == null && _payments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 18),
                      child: Text('No payments found'),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Show: 25'),
                      const Spacer(),
                      const Text('Page 1 of 1'),
                      const SizedBox(width: 12),
                      _pageButton('‹ Prev', enabled: false),
                      const SizedBox(width: 8),
                      _pageButton('Next ›', enabled: false),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterField(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          child,
        ],
      );

  Widget _filterTextField(TextEditingController controller, String hint) =>
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: const OutlineInputBorder(),
        ),
      );

  Widget _dateField(DateTime? value, ValueChanged<DateTime> onPicked) =>
      InkWell(
        onTap: () => _pickDate(value, onPicked),
        child: InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: Icon(Icons.calendar_month_outlined, size: 18),
          ),
          child: Text(
            value == null ? 'dd-mm-yyyy' : DateFormat('dd-MM-yyyy').format(value),
          ),
        ),
      );

  Widget _pageButton(String label, {required bool enabled}) => OutlinedButton(
        onPressed: enabled ? () {} : null,
        child: Text(label),
      );

  Widget _action(IconData icon, String tooltip, VoidCallback onPressed) =>
      IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, color: const Color(0xFF7A8490), size: 20),
      );
}

class _PaymentFormResult {
  const _PaymentFormResult({
    required this.bill,
    required this.amount,
    required this.date,
    required this.mode,
    required this.reference,
    required this.paidBy,
    required this.notes,
  });

  final BillModel bill;
  final double amount;
  final DateTime date;
  final String mode;
  final String reference;
  final String paidBy;
  final String notes;
}

class _PaymentFormDialog extends StatefulWidget {
  const _PaymentFormDialog({
    required this.bills,
    this.initialBill,
    this.payment,
  });

  final List<BillModel> bills;
  final BillModel? initialBill;
  final PaymentMadeModel? payment;

  @override
  State<_PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<_PaymentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? _billId = widget.initialBill?.id;
  late final _amount = TextEditingController(
    text: widget.payment?.amount.toStringAsFixed(2) ??
        widget.initialBill?.amountDue.toStringAsFixed(2) ??
        '',
  );
  late final _reference =
      TextEditingController(text: widget.payment?.reference ?? '');
  late final _paidBy = TextEditingController(text: widget.payment?.paidBy ?? '');
  late final _notes = TextEditingController(text: widget.payment?.notes ?? '');
  late DateTime _date = widget.payment?.date ?? DateTime.now();
  late String _mode = widget.payment?.mode ?? 'Bank Transfer';

  BillModel? get _selectedBill {
    for (final bill in widget.bills) {
      if (bill.id == _billId) return bill;
    }
    return null;
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _paidBy.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (value != null) setState(() => _date = value);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final bill = _selectedBill;
    if (bill == null) return;
    Navigator.pop(
      context,
      _PaymentFormResult(
        bill: bill,
        amount: double.parse(_amount.text.trim()),
        date: _date,
        mode: _mode,
        reference: _reference.text.trim(),
        paidBy: _paidBy.text.trim(),
        notes: _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.payment != null;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogHeader(
              context,
              isEditing ? 'Edit Payment' : 'New Payment',
            ),
            const Divider(height: 1),
            Flexible(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _billId,
                      decoration: const InputDecoration(
                        labelText: 'Bill # *',
                        border: OutlineInputBorder(),
                      ),
                      items: widget.bills
                          .where((bill) =>
                              !bill.isVoided &&
                              (isEditing ||
                                  bill.amountDue > 0 ||
                                  bill.id == _billId))
                          .map(
                            (bill) => DropdownMenuItem(
                              value: bill.id,
                              child: Text(
                                '${bill.billNumber} (${bill.vendorName}) '
                                '- Due: INR${bill.amountDue.toStringAsFixed(2)}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: isEditing
                          ? null
                          : (id) => setState(() {
                                _billId = id;
                                final bill = _selectedBill;
                                if (bill != null) {
                                  _amount.text =
                                      bill.amountDue.toStringAsFixed(2);
                                }
                              }),
                      validator: (value) =>
                          value == null ? 'Select a bill' : null,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        _formField(
                          'Vendor',
                          TextFormField(
                            key: ValueKey(_selectedBill?.vendorName),
                            initialValue: _selectedBill?.vendorName ?? '',
                            readOnly: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                            ),
                          ),
                        ),
                        _formField(
                          'Amount Due',
                          TextFormField(
                            key: ValueKey(_selectedBill?.amountDue),
                            initialValue:
                                'INR${_selectedBill?.amountDue.toStringAsFixed(2) ?? '0.00'}',
                            readOnly: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                            ),
                          ),
                        ),
                        _formField(
                          'Payment Date *',
                          OutlinedButton(
                            onPressed: _pickDate,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(55),
                              alignment: Alignment.centerLeft,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat('dd-MM-yyyy').format(_date),
                                  ),
                                ),
                                const Icon(Icons.calendar_month_outlined),
                              ],
                            ),
                          ),
                        ),
                        _formField(
                          'Amount Paid *',
                          TextFormField(
                            controller: _amount,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final amount =
                                  double.tryParse(value?.trim() ?? '');
                              final bill = _selectedBill;
                              if (amount == null || amount <= 0) {
                                return 'Enter an amount greater than zero';
                              }
                              if (bill != null) {
                                final allowed = isEditing
                                    ? bill.amountDue +
                                        (widget.payment?.amount ?? 0)
                                    : bill.amountDue;
                                if (amount > allowed) {
                                  return 'Amount exceeds the bill amount due';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        _formField(
                          'Payment Mode *',
                          DropdownButtonFormField<String>(
                            initialValue: _mode,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              'Bank Transfer',
                              'Cash',
                              'Cheque',
                              'UPI',
                              'Card',
                              'Other',
                            ]
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) setState(() => _mode = value);
                            },
                          ),
                        ),
                        _formField(
                          'Reference #',
                          TextFormField(
                            controller: _reference,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Cheque or TXN ID',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        _formField(
                          'Paid By',
                          TextFormField(
                            controller: _paidBy,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        _formField(
                          'Notes',
                          TextFormField(
                            controller: _notes,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _save,
                    child: Text(isEditing ? 'Save Payment' : 'Save Payment'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(String label, Widget child) => SizedBox(
        width: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(label),
            ),
            child,
          ],
        ),
      );
}

class _PaymentDetailDialog extends StatelessWidget {
  const _PaymentDetailDialog({
    required this.payment,
    required this.onDownload,
    required this.onSendMail,
    required this.onSendWhatsApp,
  });

  final PaymentMadeModel payment;
  final VoidCallback onDownload;
  final VoidCallback onSendMail;
  final VoidCallback onSendWhatsApp;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy').format(payment.date);
    final narrow = MediaQuery.sizeOf(context).width < 780;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 20),
              child: narrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _paymentHeading(date)),
                            _closeButton(context),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _paymentActions(),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _paymentHeading(date)),
                        _paymentActions(),
                        _closeButton(context),
                      ],
                    ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 30, 28, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount Paid',
                      style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'INR${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF123456),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 22),
                      child: Divider(),
                    ),
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _detailLine('Paid By', _display(payment.paidBy)),
                    _detailLine('Bill Paid', payment.billNumber),
                    _detailLine(
                      'Vendor Invoice #',
                      _display(payment.vendorInvoiceNumber),
                    ),
                    _detailLine('Reference #', _display(payment.reference)),
                    _detailLine('Payment Mode', payment.mode),
                    _detailLine('Notes', _display(payment.notes)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentHeading(String date) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            payment.vendorName,
            style: const TextStyle(
              color: Color(0xFF123456),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text('${payment.paymentNumber} | $date'),
        ],
      );

  Widget _paymentActions() => Wrap(
        spacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: onDownload,
            icon: const Icon(Icons.download_outlined, size: 17),
            label: const Text('Download PDF'),
          ),
          OutlinedButton.icon(
            onPressed: onSendMail,
            icon: const Icon(Icons.mail_outline, size: 17),
            label: const Text('Send Mail'),
          ),
          OutlinedButton.icon(
            onPressed: onSendWhatsApp,
            icon: const Icon(Icons.chat_outlined, size: 17),
            label: const Text('Send WhatsApp'),
          ),
        ],
      );

  Widget _closeButton(BuildContext context) => IconButton(
        onPressed: () => Navigator.pop(context),
        tooltip: 'Close',
        icon: const Icon(Icons.close, color: Color(0xFF888888)),
      );

  String _display(String value) => value.trim().isEmpty ? 'N/A' : value;

  Widget _detailLine(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$label:',
                style: const TextStyle(color: Color(0xFF555555)),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Color(0xFF424242)),
              ),
            ),
          ],
        ),
      );
}

Widget _dialogHeader(BuildContext context, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF123456),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
