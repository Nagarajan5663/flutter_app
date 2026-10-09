import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/sales_glass_widgets.dart';

import '../widgets/sales_dialog_helpers.dart';
import 'payment_received_filter.dart';
import 'payment_received_model.dart';
import 'payment_received_repository.dart';
import 'widgets/add_payment_received_dialog.dart';
import 'widgets/payment_received_preview_dialog.dart';

class PaymentsReceivedPage extends StatefulWidget {
  const PaymentsReceivedPage({super.key});

  @override
  State<PaymentsReceivedPage> createState() => _PaymentsReceivedPageState();
}

class _PaymentsReceivedPageState extends State<PaymentsReceivedPage> {
  final PaymentReceivedRepository _repository =
      InMemoryPaymentReceivedRepository();

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
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded successfully')));
  }

  Future<void> _deletePayment(PaymentReceivedModel payment) async {
    if (payment.id == null) return;
    await _repository.deletePayment(payment.id!);
    await _loadPayments();
  }

  Future<void> _confirmDeletePayment(PaymentReceivedModel payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text('Delete payment ${payment.paymentNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _deletePayment(payment);
        if (mounted) _showMessage('Payment deleted.');
      } catch (error) {
        if (mounted) {
          _showMessage(
            error.toString().replaceFirst('Exception: ', ''),
            isError: true,
          );
        }
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFAB2A2A) : const Color(0xFF1E7B34),
      ),
    );
  }

  Future<void> _previewPayment(PaymentReceivedModel payment) async {
    await showDialog<void>(
      context: context,
      builder: (_) => PaymentReceivedPreviewDialog(
        payment: payment,
        onDownloadPdf: () => _downloadPaymentPdf(payment),
        onSendMail: () => _sendPaymentMail(payment),
      ),
    );
  }

  Future<void> _downloadPaymentPdf(PaymentReceivedModel payment) async {
    final pdf = pw.Document();
    final money = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'INR',
      decimalDigits: 2,
    );
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'PAYMENT RECEIVED',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(payment.customerName,
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text(
              '${payment.paymentNumber} | ${DateFormat('dd MMM yyyy').format(payment.paymentDate)}',
            ),
            pw.SizedBox(height: 28),
            pw.Text('Amount Received', style: const pw.TextStyle(fontSize: 15)),
            pw.SizedBox(height: 6),
            pw.Text(
              money.format(payment.amountReceived),
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Payment Details',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              data: [
                ['Paid To', payment.customerName],
                ['Invoice Paid', '#${payment.invoiceNumber}'],
                ['Payment Mode', payment.paymentMode],
                [
                  'UTR / Reference #',
                  payment.utrReference.isEmpty ? 'N/A' : payment.utrReference,
                ],
                ['Remarks', payment.remarks.isEmpty ? 'N/A' : payment.remarks],
              ],
            ),
          ],
        ),
      ),
    );
    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${payment.paymentNumber}.pdf',
      );
    } catch (error) {
      if (mounted) {
        _showMessage('Unable to create payment PDF: $error', isError: true);
      }
    }
  }

  Future<void> _sendPaymentMail(PaymentReceivedModel payment) async {
    final recipientController = TextEditingController();
    try {
      final recipient = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Send Payment Details'),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: recipientController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Recipient Email',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                recipientController.text.trim(),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (recipient == null || recipient.isEmpty || !mounted) return;
      final uri = Uri(
        scheme: 'mailto',
        path: recipient,
        queryParameters: {
          'subject': 'Payment ${payment.paymentNumber}',
          'body':
              'Payment received from ${payment.customerName}. Invoice #${payment.invoiceNumber}. Amount: INR ${payment.amountReceived.toStringAsFixed(2)}.',
        },
      );
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Unable to open the default email application.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      recipientController.dispose();
    }
  }

  Future<void> _clonePayment(PaymentReceivedModel payment) async {
    try {
      final clone = await _repository.addPayment(
        PaymentReceivedModel(
          paymentNumber: '',
          customerId: payment.customerId,
          customerName: payment.customerName,
          invoiceId: payment.invoiceId,
          invoiceNumber: payment.invoiceNumber,
          paymentDate: payment.paymentDate,
          amountReceived: payment.amountReceived,
          paymentMode: payment.paymentMode,
          utrReference: payment.utrReference,
          remarks: payment.remarks,
        ),
      );
      await _loadPayments();
      if (mounted) _showMessage('Payment ${clone.paymentNumber} created.');
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    }
  }

  Future<void> _editPayment(PaymentReceivedModel payment) async {
    final amountController = TextEditingController(
      text: payment.amountReceived.toStringAsFixed(2),
    );
    final referenceController =
        TextEditingController(text: payment.utrReference);
    final remarksController = TextEditingController(text: payment.remarks);
    DateTime paymentDate = payment.paymentDate;
    String paymentMode = payment.paymentMode;
    var saving = false;
    try {
      final updated = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Edit Payment ${payment.paymentNumber}'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount Received',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: paymentMode,
                      decoration: const InputDecoration(
                        labelText: 'Payment Mode',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        'Bank Transfer',
                        'Cash',
                        'Cheque',
                        'UPI',
                        'Card',
                      ]
                          .map((mode) => DropdownMenuItem(
                                value: mode,
                                child: Text(mode),
                              ))
                          .toList(),
                      onChanged: (mode) {
                        if (mode != null) {
                          setDialogState(() => paymentMode = mode);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Payment Date'),
                      subtitle:
                          Text(DateFormat('dd MMM yyyy').format(paymentDate)),
                      trailing: IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: paymentDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setDialogState(() => paymentDate = date);
                          }
                        },
                      ),
                    ),
                    TextField(
                      controller: referenceController,
                      decoration: const InputDecoration(
                        labelText: 'UTR / Reference #',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: remarksController,
                      decoration: const InputDecoration(
                        labelText: 'Remarks',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        final amount =
                            double.tryParse(amountController.text.trim());
                        if (amount == null || amount <= 0) {
                          _showMessage(
                            'Enter an amount greater than zero.',
                            isError: true,
                          );
                          return;
                        }
                        setDialogState(() => saving = true);
                        try {
                          await _repository.updatePayment(
                            payment.id!,
                            PaymentReceivedModel(
                              id: payment.id,
                              paymentNumber: payment.paymentNumber,
                              customerId: payment.customerId,
                              customerName: payment.customerName,
                              invoiceId: payment.invoiceId,
                              invoiceNumber: payment.invoiceNumber,
                              paymentDate: paymentDate,
                              amountReceived: amount,
                              paymentMode: paymentMode,
                              utrReference: referenceController.text.trim(),
                              remarks: remarksController.text.trim(),
                            ),
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, true);
                          }
                        } catch (error) {
                          if (!dialogContext.mounted) return;
                          setDialogState(() => saving = false);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(error
                                  .toString()
                                  .replaceFirst('Exception: ', '')),
                            ),
                          );
                        }
                      },
                child: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      );
      if (updated == true && mounted) await _loadPayments();
    } finally {
      amountController.dispose();
      referenceController.dispose();
      remarksController.dispose();
    }
  }

  Widget _paymentAction({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      icon: Icon(icon, size: 18, color: const Color(0xFF777777)),
    );
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
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123456))),
                ),
                ElevatedButton.icon(
                  onPressed: _openAddPayment,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Payment'),
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
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B5B5B))),
                      const SizedBox(height: 6),
                      SizedBox(
                          width: 170,
                          child: salesFilterTextField(
                              customerController, 'Customer name...')),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoice #',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B5B5B))),
                      const SizedBox(height: 6),
                      SizedBox(
                          width: 150,
                          child: salesFilterTextField(
                              invoiceController, 'Invoice number...')),
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
                    onPressed: _loadPayments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7DD1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)),
                    ),
                    child: const Text('Filter'),
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
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0x4FFFFFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xC7FFFFFF)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final tableWidth =
                      constraints.maxWidth < 900 ? 900.0 : constraints.maxWidth;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: tableWidth,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(14)),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: SalesHeaderText('PAYMENT DATE')),
                                Expanded(
                                    flex: 2,
                                    child: SalesHeaderText('PAYMENT #')),
                                Expanded(
                                    flex: 2,
                                    child: SalesHeaderText('INVOICE #')),
                                Expanded(
                                    flex: 3,
                                    child: SalesHeaderText('CUSTOMER NAME')),
                                Expanded(
                                    flex: 2, child: SalesHeaderText('MODE')),
                                Expanded(
                                    flex: 2,
                                    child: SalesHeaderText('AMOUNT RECEIVED')),
                                Expanded(
                                    flex: 2,
                                    child: SalesHeaderText('UTR/REFERENCE')),
                                Expanded(
                                    flex: 3, child: SalesHeaderText('ACTIONS')),
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
                              width: tableWidth,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 24),
                              child: const Text(
                                'No payments received yet. Click "+ New Payment" to add one!',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF42474D)),
                              ),
                            )
                          else
                            ..._payments.map((payment) {
                              return Column(
                                children: [
                                  Container(
                                    width: tableWidth,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            DateFormat('dd MMM yyyy')
                                                .format(payment.paymentDate),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: Text(payment.paymentNumber)),
                                        Expanded(
                                            flex: 2,
                                            child: Text(payment.invoiceNumber)),
                                        Expanded(
                                            flex: 3,
                                            child: Text(payment.customerName,
                                                overflow:
                                                    TextOverflow.ellipsis)),
                                        Expanded(
                                            flex: 2,
                                            child: Text(payment.paymentMode)),
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                'INR ${payment.amountReceived.toStringAsFixed(2)}')),
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                payment.utrReference.isEmpty
                                                    ? '-'
                                                    : payment.utrReference)),
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              _paymentAction(
                                                tooltip: 'Preview',
                                                icon: Icons.visibility,
                                                onPressed: () =>
                                                    _previewPayment(payment),
                                              ),
                                              _paymentAction(
                                                tooltip: 'Edit',
                                                icon: Icons.edit,
                                                onPressed: () =>
                                                    _editPayment(payment),
                                              ),
                                              _paymentAction(
                                                tooltip: 'Clone',
                                                icon: Icons.content_copy,
                                                onPressed: () =>
                                                    _clonePayment(payment),
                                              ),
                                              _paymentAction(
                                                tooltip: 'Delete',
                                                icon: Icons.delete,
                                                onPressed: () =>
                                                    _confirmDeletePayment(
                                                        payment),
                                              ),
                                            ],
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
