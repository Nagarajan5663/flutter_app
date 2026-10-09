import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../widgets/sales_glass_widgets.dart';

import '../widgets/sales_dialog_helpers.dart';
import 'invoice_filter.dart';
import 'invoice_model.dart';
import 'invoice_repository.dart';
import '../delivery_challans/delivery_challan_repository.dart';
import '../payments_received/payment_received_model.dart';
import '../payments_received/payment_received_repository.dart';
import '../payments_received/widgets/add_payment_received_dialog.dart';
import 'widgets/add_invoice_dialog.dart';
import 'widgets/invoice_preview_dialog.dart';

class InvoicesPage extends StatefulWidget {
  final VoidCallback? onOpenDeliveryChallans;
  final VoidCallback? onOpenPaymentsReceived;
  const InvoicesPage({
    super.key,
    this.onOpenDeliveryChallans,
    this.onOpenPaymentsReceived,
  });

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final Set<String> _workflowBusyIds = {};
  final InvoiceRepository _repository = InMemoryInvoiceRepository();
  final DeliveryChallanRepository _challanRepository =
      InMemoryDeliveryChallanRepository();
  final PaymentReceivedRepository _paymentRepository =
      InMemoryPaymentReceivedRepository();

  List<InvoiceModel> _invoices = [];
  bool _isLoading = true;
  String? _loadError;

  final customerController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;

  String statusFilter = 'All';
  final statusOptions = const [
    'All',
    'Draft',
    'Sent',
    'Void',
    'Unpaid',
    'Partially Paid',
    'Paid',
  ];

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
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    late final List<InvoiceModel> result;
    try {
      result = await _repository.getInvoices(filter: _currentFilter);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _invoices = result;
      _isLoading = false;
    });
  }

  Future<void> _openAddInvoice() async {
    try {
      final invoice = await showDialog<InvoiceModel>(
        context: context,
        barrierColor: const Color(0x9A12202C),
        barrierDismissible: false,
        builder: (_) => const AddInvoiceDialog(),
      );
      if (!mounted || invoice == null) return;
      if (invoice.id == null) await _repository.addInvoice(invoice);
      await _loadInvoices();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice created successfully')));
    } catch (error) {
      if (mounted)
        _showMessage(error.toString().replaceFirst('Exception: ', ''),
            isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor:
          isError ? const Color(0xFFAB2A2A) : const Color(0xFF1E7B34),
    ));
  }

  Future<void> _createOrOpenChallan(InvoiceModel invoice) async {
    if (invoice.documentStatus == 'Void') {
      _showMessage('A void invoice cannot be converted to a Delivery Challan.',
          isError: true);
      return;
    }
    if (invoice.approvalStatus != 'Approved') {
      _showMessage('Invoice must be approved before conversion.',
          isError: true);
      return;
    }
    final id = invoice.id;
    if (id == null || !_workflowBusyIds.add(id)) return;
    setState(() {});
    try {
      final challan = await _challanRepository.createFromInvoice(id);
      await _loadInvoices();
      if (!mounted) return;
      _showMessage('Delivery Challan ${challan.challanNumber} is ready.');
      widget.onOpenDeliveryChallans?.call();
    } catch (error) {
      if (mounted)
        _showMessage(error.toString().replaceFirst('Exception: ', ''),
            isError: true);
    } finally {
      _workflowBusyIds.remove(id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _setInvoiceStatus(InvoiceModel invoice, String status) async {
    final id = invoice.id;
    if (id == null || !_workflowBusyIds.add(id)) return;
    setState(() {});
    try {
      if (status == 'Approved') {
        if (invoice.documentStatus == 'Void') {
          throw Exception('A void invoice cannot be approved.');
        }
        await _repository.approveInvoice(id);
      } else {
        await _repository.updateStatus(id, status);
      }
      await _loadInvoices();
      if (mounted) {
        _showMessage(
          status == 'Approved'
              ? 'Invoice approved.'
              : 'Invoice status updated to $status.',
        );
      }
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      _workflowBusyIds.remove(id);
      if (mounted) setState(() {});
    }
  }

  Future<void> _editInvoice(InvoiceModel invoice) async {
    final edited = await showDialog<InvoiceModel>(
      context: context,
      barrierColor: const Color(0x9A12202C),
      barrierDismissible: false,
      builder: (_) => AddInvoiceDialog(invoice: invoice),
    );
    if (edited == null || !mounted) return;
    await _loadInvoices();
    if (mounted) _showMessage('Invoice updated successfully.');
  }

  Future<void> _cloneInvoice(InvoiceModel invoice) async {
    final id = invoice.id;
    if (id == null) return;
    try {
      final clone = await _repository.cloneInvoice(id);
      if (!mounted) return;
      await _loadInvoices();
      if (!mounted) return;
      _showMessage('Invoice ${clone.invoiceNumber} cloned as a draft.');
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    }
  }

  Future<void> _confirmDeleteInvoice(InvoiceModel invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Delete invoice ${invoice.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFAB2A2A),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _deleteInvoice(invoice);
  }

  Future<void> _recordInvoicePayment(InvoiceModel invoice) async {
    if (invoice.id == null || invoice.amountDue <= 0) {
      _showMessage('This invoice has no balance due.', isError: true);
      return;
    }
    try {
      final payment = await showDialog<PaymentReceivedModel>(
        context: context,
        barrierColor: const Color(0x9A12202C),
        barrierDismissible: false,
        builder: (_) => AddPaymentReceivedDialog(initialInvoice: invoice),
      );
      if (payment == null || !mounted) return;
      await _paymentRepository.addPayment(payment);
      await _loadInvoices();
      if (mounted) {
        Navigator.of(context).pop();
        widget.onOpenPaymentsReceived?.call();
      }
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    }
  }

  Future<void> _sendInvoiceEmail(InvoiceModel invoice) async {
    if (invoice.customerEmail.trim().isEmpty) {
      _showMessage('This customer does not have an email address.',
          isError: true);
      return;
    }
    final subjectController = TextEditingController(
      text: 'Invoice ${invoice.invoiceNumber} - ${invoice.customerName}',
    );
    var sending = false;
    String? errorMessage;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Send Invoice'),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Color(0xFFAB2A2A)),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: sending ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: sending
                    ? null
                    : () async {
                        setDialogState(() {
                          sending = true;
                          errorMessage = null;
                        });
                        try {
                          await _repository.sendInvoiceEmail(
                            id: invoice.id!,
                            subject: subjectController.text.trim(),
                          );
                          if (invoice.documentStatus != 'Sent') {
                            await _repository.updateStatus(
                              invoice.id!,
                              'Sent',
                            );
                            await _loadInvoices();
                          }
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invoice email sent successfully.'),
                            ),
                          );
                        } catch (error) {
                          setDialogState(() {
                            sending = false;
                            errorMessage = error
                                .toString()
                                .replaceFirst('Exception: ', '');
                          });
                        }
                      },
                child: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Email'),
              ),
            ],
          ),
        ),
      );
    } finally {
      subjectController.dispose();
    }
  }

  Future<void> _downloadInvoicePdf(InvoiceModel invoice) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            'INVOICE',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Invoice: ${invoice.invoiceNumber}'),
          pw.Text('Customer: ${invoice.customerName}'),
          pw.Text('Date: ${DateFormat('dd-MM-yyyy').format(invoice.date)}'),
          pw.Text('Status: ${invoice.documentStatus}'),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: const ['Item', 'Description', 'Qty', 'Rate', 'Amount'],
            data: [
              for (final item in invoice.items)
                [
                  item.itemName,
                  item.description,
                  item.quantity.toStringAsFixed(2),
                  'INR ${item.rate.toStringAsFixed(2)}',
                  'INR ${item.amount.toStringAsFixed(2)}',
                ],
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Subtotal: INR ${invoice.subTotal.toStringAsFixed(2)}'),
                pw.Text('Tax: INR ${invoice.tax.toStringAsFixed(2)}'),
                pw.Text(
                  'Total: INR ${invoice.total.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Amount Paid: INR ${invoice.amountPaid.toStringAsFixed(2)}',
                ),
                pw.Text(
                  'Amount Due: INR ${invoice.amountDue.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${invoice.invoiceNumber}.pdf',
      );
    } catch (error) {
      if (mounted) {
        _showMessage('Unable to create invoice PDF: $error', isError: true);
      }
    }
  }

  void _previewInvoice(InvoiceModel invoice) {
    showDialog<void>(
      context: context,
      builder: (_) => InvoicePreviewDialog(
        invoice: invoice,
        onDownloadPdf: () => _downloadInvoicePdf(invoice),
        onSendEmail: () => _sendInvoiceEmail(invoice),
        onConvertToDeliveryChallan: () => _createOrOpenChallan(invoice),
        onRecordPayment: () => _recordInvoicePayment(invoice),
        onVoid: () => _setInvoiceStatus(invoice, 'Void'),
      ),
    );
  }

  Future<void> _deleteInvoice(InvoiceModel invoice) async {
    if (invoice.id == null) return;
    try {
      await _repository.deleteInvoice(invoice.id!);
      await _loadInvoices();
    } catch (error) {
      if (mounted)
        _showMessage(error.toString().replaceFirst('Exception: ', ''),
            isError: true);
    }
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
      case 'Sent':
      case 'Approved':
        return const Color(0xFF1E7B34);
      case 'Draft':
        return const Color(0xFFB8860B);
      default:
        return const Color(0xFFAB2A2A);
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Sent':
      case 'Approved':
        return const Color(0xFFE3F6E8);
      case 'Draft':
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
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123456))),
                ),
                ElevatedButton.icon(
                  onPressed: _openAddInvoice,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Invoice'),
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
                      const Text('Status',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B5B5B))),
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
                            dropdownColor: Colors.white,
                            items: statusOptions
                                .map((s) =>
                                    DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
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
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5B5B5B))),
                      const SizedBox(height: 6),
                      SizedBox(
                          width: 180,
                          child: salesFilterTextField(
                              customerController, 'Customer name...')),
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
                    onPressed: _loadInvoices,
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
            LayoutBuilder(
              builder: (context, constraints) {
                const tableWidth = 1100.0;
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0x4FFFFFFF),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xC7FFFFFF)),
                  ),
                  child: FittedBox(
                    alignment: Alignment.topLeft,
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: tableWidth,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(14)),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                    flex: 17, child: SalesHeaderText('DATE')),
                                Expanded(
                                    flex: 17,
                                    child: SalesHeaderText('INVOICE #')),
                                Expanded(
                                    flex: 20,
                                    child:
                                        SalesHeaderText('SO # / ESTIMATE #')),
                                Expanded(
                                    flex: 25,
                                    child: SalesHeaderText('CUSTOMER NAME')),
                                Expanded(
                                    flex: 15,
                                    child: SalesHeaderText('DUE DATE')),
                                Expanded(
                                    flex: 20, child: SalesHeaderText('STATUS')),
                                Expanded(
                                    flex: 22, child: SalesHeaderText('AMOUNT')),
                                Expanded(
                                    flex: 24,
                                    child: SalesHeaderText('ACTIONS')),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFD9DEE5)),
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_loadError != null)
                            Container(
                                width: tableWidth,
                                padding: const EdgeInsets.all(24),
                                child: Text(_loadError!,
                                    style: const TextStyle(color: Colors.red)))
                          else if (_invoices.isEmpty)
                            Container(
                              width: tableWidth,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 24),
                              child: const Text(
                                'No invoices found. Click "+ New Invoice" to add one!',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF42474D)),
                              ),
                            )
                          else
                            ..._invoices.map((invoice) {
                              return Column(
                                children: [
                                  Container(
                                    width: tableWidth,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 14),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 17,
                                          child: Text(
                                            '${invoice.date.day.toString().padLeft(2, '0')}-${invoice.date.month.toString().padLeft(2, '0')}-${invoice.date.year}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 17,
                                          child: Text(
                                            invoice.invoiceNumber,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 20,
                                          child: Text(
                                              'SO: ${invoice.soNumber ?? '-'}\nEST: ${invoice.estimateNumber ?? '-'}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        ),
                                        Expanded(
                                          flex: 25,
                                          child: Text(
                                            invoice.customerName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 15,
                                          child: Text(
                                            invoice.dueDate == null
                                                ? '-'
                                                : '${invoice.dueDate!.day.toString().padLeft(2, '0')}-${invoice.dueDate!.month.toString().padLeft(2, '0')}-${invoice.dueDate!.year}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 20,
                                          child: Container(
                                            height: 38,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusBg(
                                                invoice.approvalStatus ==
                                                        'Approved'
                                                    ? 'Approved'
                                                    : invoice.documentStatus,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: invoice.approvalStatus ==
                                                        'Approved'
                                                    ? 'Approved'
                                                    : invoice.documentStatus,
                                                isExpanded: true,
                                                dropdownColor: Colors.white,
                                                style: TextStyle(
                                                  color: _statusColor(
                                                    invoice.approvalStatus ==
                                                            'Approved'
                                                        ? 'Approved'
                                                        : invoice
                                                            .documentStatus,
                                                  ),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                items: const [
                                                  'Sent',
                                                  'Draft',
                                                  'Void',
                                                  'Approved',
                                                ]
                                                    .map(
                                                      (status) =>
                                                          DropdownMenuItem(
                                                        value: status,
                                                        enabled: status !=
                                                                'Approved' ||
                                                            invoice.documentStatus !=
                                                                'Void',
                                                        child: Text(status),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: _workflowBusyIds
                                                        .contains(
                                                  invoice.id,
                                                )
                                                    ? null
                                                    : (status) {
                                                        if (status != null) {
                                                          _setInvoiceStatus(
                                                            invoice,
                                                            status,
                                                          );
                                                        }
                                                      },
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 22,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'INR ${invoice.total.toStringAsFixed(2)}',
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 24,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                tooltip: 'Preview Invoice',
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 32,
                                                  minHeight: 32,
                                                ),
                                                icon: const Icon(
                                                  Icons.visibility_outlined,
                                                  size: 18,
                                                  color: Color(0xFF777777),
                                                ),
                                                onPressed: invoice.id == null ||
                                                        _workflowBusyIds
                                                            .contains(
                                                                invoice.id)
                                                    ? null
                                                    : () => _previewInvoice(
                                                        invoice),
                                              ),
                                              IconButton(
                                                tooltip: 'Edit Invoice',
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 32,
                                                  minHeight: 32,
                                                ),
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 18,
                                                  color: Color(0xFF777777),
                                                ),
                                                onPressed: invoice.id == null ||
                                                        _workflowBusyIds
                                                            .contains(
                                                                invoice.id)
                                                    ? null
                                                    : () =>
                                                        _editInvoice(invoice),
                                              ),
                                              IconButton(
                                                tooltip: 'Clone Invoice',
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 32,
                                                  minHeight: 32,
                                                ),
                                                icon: const Icon(
                                                  Icons.content_copy_outlined,
                                                  size: 18,
                                                  color: Color(0xFF777777),
                                                ),
                                                onPressed: invoice.id == null ||
                                                        _workflowBusyIds
                                                            .contains(
                                                                invoice.id)
                                                    ? null
                                                    : () =>
                                                        _cloneInvoice(invoice),
                                              ),
                                              IconButton(
                                                tooltip: 'Delete Invoice',
                                                visualDensity:
                                                    VisualDensity.compact,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 32,
                                                  minHeight: 32,
                                                ),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 18,
                                                  color: Color(0xFF777777),
                                                ),
                                                onPressed: invoice.id == null ||
                                                        _workflowBusyIds
                                                            .contains(
                                                                invoice.id)
                                                    ? null
                                                    : () =>
                                                        _confirmDeleteInvoice(
                                                            invoice),
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
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
