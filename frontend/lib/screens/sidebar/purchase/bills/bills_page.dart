import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../shared/glass_modal_shell.dart';
import 'bill_filter.dart';
import 'bill_model.dart';
import 'bill_repository.dart';
import '../../../../utils/pdf_file_download.dart';
import 'widgets/add_bill_dialog.dart';

// ============================================================
// BILLS PAGE
// ============================================================

class BillsPage extends StatefulWidget {
  const BillsPage({
    super.key,
  });

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  final BillRepository _repository = InMemoryBillRepository();

  List<BillModel> _bills = [];

  bool _isLoading = true;

  String? _errorMessage;

  final TextEditingController vendorController = TextEditingController();

  DateTime? dateFrom;

  DateTime? dateTo;

  String statusFilter = 'All';

  // BillModel uses these exact statuses.
  final List<String> statusOptions = const [
    'All',
    'Unpaid',
    'Partially Paid',
    'Paid',
    'Void',
  ];

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _loadBills();
  }

  @override
  void dispose() {
    vendorController.dispose();

    super.dispose();
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  BillFilter get _currentFilter => BillFilter(
        status: statusFilter,
        vendorName: vendorController.text,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  // ==========================================================
  // LOAD
  // ==========================================================

  Future<void> _loadBills() async {
    setState(() {
      _isLoading = true;

      _errorMessage = null;
    });

    try {
      final List<BillModel> result = await _repository.getBills(
        filter: _currentFilter,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _bills = result;

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _errorMessage = error.toString();
      });
    }
  }

  // ==========================================================
  // NEW BILL
  // ==========================================================

  Future<void> _openAddBill() async {
    final BillModelDraft? draft = await showDialog<BillModelDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddBillDialog(),
    );

    if (!mounted || draft == null) {
      return;
    }

    final BillModel bill = BillModel(
      billNumber: draft.billNumber,
      vendorInvoiceNumber: draft.vendorInvoiceNumber,
      invoiceAttachmentPath: draft.invoiceAttachmentPath,
      vendorId: draft.vendorId,
      vendorName: draft.vendorName,
      purchaseOrderId: draft.purchaseOrderId,
      purchaseOrderNumber: draft.purchaseOrderNumber,
      billDate: draft.billDate,
      dueDate: draft.dueDate,
      items: draft.items,
      taxAmount: draft.taxAmount,
    );

    try {
      await _repository.addBill(
        bill,
      );

      await _loadBills();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Bill created successfully',
          ),
          backgroundColor: Color(
            0xFF1E7B34,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create bill: $error',
          ),
          backgroundColor: const Color(
            0xFFAB2A2A,
          ),
        ),
      );
    }
  }

  Future<void> _editBill(BillModel bill) async {
    if (bill.isVoided) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voided bills cannot be edited')),
      );
      return;
    }

    final draft = await showDialog<BillModelDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddBillDialog(initialBill: bill),
    );
    if (!mounted || draft == null) return;

    final updatedBill = BillModel(
      id: bill.id,
      billNumber: bill.billNumber,
      vendorInvoiceNumber: draft.vendorInvoiceNumber,
      invoiceAttachmentPath: draft.invoiceAttachmentPath,
      vendorId: draft.vendorId,
      vendorName: draft.vendorName,
      purchaseOrderId: draft.purchaseOrderId,
      purchaseOrderNumber: draft.purchaseOrderNumber,
      billDate: draft.billDate,
      dueDate: draft.dueDate,
      items: draft.items,
      taxAmount: draft.taxAmount,
      amountPaid: bill.amountPaid,
      isVoided: bill.isVoided,
    );

    try {
      await _repository.updateBill(updatedBill);
      await _loadBills();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill updated successfully')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update bill: $error')),
      );
    }
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> _deleteBill(
    BillModel bill,
  ) async {
    if (bill.id == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Bill',
          ),
          content: Text(
            'Delete ${bill.billNumber}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _repository.deleteBill(
        bill.id!,
      );

      await _loadBills();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Bill deleted successfully',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete bill: $error',
          ),
          backgroundColor: const Color(
            0xFFAB2A2A,
          ),
        ),
      );
    }
  }

  Future<void> _previewBill(BillModel bill) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => _BillPreviewDialog(
        bill: bill,
        onDownloadPdf: _downloadBillPdf,
        onRecordPayment: _recordBillPayment,
        onVoidBill: _voidBill,
      ),
    );
  }

  Future<BillModel?> _recordBillPayment(BillModel bill) async {
    final id = bill.id;
    if (id == null ||
        id.trim().isEmpty ||
        bill.amountDue <= 0 ||
        bill.isVoided) {
      return null;
    }

    final details = await showDialog<_BillPaymentDetails>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BillPaymentDialog(bill: bill),
    );
    if (details == null) return null;

    try {
      final updated = await _repository.recordPayment(
        id,
        details.amount,
        details.paymentDate,
        details.paymentMode,
        details.reference,
      );
      await _loadBills();
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded successfully')),
      );
      return updated;
    } catch (error) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to record payment: $error')),
      );
      return null;
    }
  }

  Future<BillModel?> _voidBill(BillModel bill) async {
    final id = bill.id;
    if (id == null || id.trim().isEmpty || bill.isVoided) return null;

    try {
      final updated = await _repository.voidBill(id);
      if (!mounted) return null;

      final voidedBill = updated.copyWith(isVoided: true);
      setState(() {
        _bills = _bills
            .where((existing) => existing.id != id)
            .toList(growable: false);

        if (statusFilter == 'All' || statusFilter == 'Void') {
          _bills = [..._bills, voidedBill];
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill voided successfully')),
      );
      return voidedBill;
    } catch (error) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to void bill: $error')),
      );
      return null;
    }
  }

  Future<void> _downloadBillPdf(BillModel bill) async {
    final currency = NumberFormat('#,##0.00', 'en_IN');
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text(
            bill.vendorName,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Bill ${bill.billNumber} | ${_fmt(bill.billDate)}'),
          if (bill.vendorInvoiceNumber.isNotEmpty)
            pw.Text('Vendor Invoice #: ${bill.vendorInvoiceNumber}'),
          if (bill.purchaseOrderNumber?.isNotEmpty == true)
            pw.Text('Purchase Order: ${bill.purchaseOrderNumber}'),
          pw.SizedBox(height: 24),
          pw.TableHelper.fromTextArray(
            headers: const ['Item & Description', 'Qty', 'Rate', 'Amount'],
            data: bill.items
                .map(
                  (item) => [
                    [
                      item.itemName,
                      if (item.description.trim().isNotEmpty)
                        item.description.trim(),
                    ].join('\n'),
                    item.qty.toStringAsFixed(2),
                    'INR ${currency.format(item.rate)}',
                    'INR ${currency.format(item.amount)}',
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Sub Total: INR ${currency.format(bill.subTotal)}'),
                pw.Text('Tax: INR ${currency.format(bill.taxAmount)}'),
                pw.Text('Total: INR ${currency.format(bill.total)}'),
                pw.Text('Amount Paid: INR ${currency.format(bill.amountPaid)}'),
                pw.Text('Amount Due: INR ${currency.format(bill.amountDue)}'),
              ],
            ),
          ),
        ],
      ),
    );

    try {
      final filename =
          'bill-${bill.billNumber.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '-')}.pdf';
      final downloaded = await downloadPdfFile(await document.save(), filename);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            downloaded ? 'Bill PDF downloaded' : 'PDF download cancelled',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to download bill PDF: $error')),
      );
    }
  }

  // ==========================================================
  // CLEAR FILTER
  // ==========================================================

  void _clearFilters() {
    statusFilter = 'All';

    vendorController.clear();

    dateFrom = null;

    dateTo = null;

    _loadBills();
  }

  // ==========================================================
  // DATE PICKER
  // ==========================================================

  Future<void> _pickDate(
    DateTime? initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      onPicked(
        picked,
      );
    }
  }

  String _fmt(
    DateTime? date,
  ) {
    if (date == null) {
      return '-';
    }

    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // ==========================================================
  // STATUS COLORS
  // ==========================================================

  Color _statusBg(
    String status,
  ) {
    switch (status) {
      case 'Paid':
        return const Color(
          0xFFE3F6E8,
        );

      case 'Partially Paid':
        return const Color(
          0xFFFFF3D8,
        );

      case 'Void':
        return const Color(0xFFE5E7EB);

      default:
        return const Color(
          0xFFF4E3E3,
        );
    }
  }

  Color _statusFg(
    String status,
  ) {
    switch (status) {
      case 'Paid':
        return const Color(
          0xFF1E7B34,
        );

      case 'Partially Paid':
        return const Color(
          0xFF986A00,
        );

      case 'Void':
        return const Color(0xFF596579);

      default:
        return const Color(
          0xFFAB2A2A,
        );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return GlassPageBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Vendor Bills',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(
                        0xFF123456,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _loadBills,
                  tooltip: 'Refresh Bills',
                  icon: const Icon(
                    Icons.refresh,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                GlassButton(
                  onPressed: _openAddBill,
                  icon: Icons.add,
                  label: 'New Bill',
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // FILTERS
            // ==================================================

            GlassPanel(
              padding: const EdgeInsets.all(
                20,
              ),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  _filterField(
                    label: 'Status',
                    child: Container(
                      width: 175,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFF8F9FA,
                        ),
                        borderRadius: BorderRadius.circular(
                          7,
                        ),
                        border: Border.all(
                          color: const Color(
                            0xFFD9DEE5,
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: statusFilter,
                          isExpanded: true,
                          items: statusOptions.map(
                            (
                              String status,
                            ) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(
                                  status,
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (
                            String? value,
                          ) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              statusFilter = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  _filterField(
                    label: 'Vendor Name',
                    child: SizedBox(
                      width: 180,
                      child: _filterTextField(
                        vendorController,
                        'Vendor name...',
                      ),
                    ),
                  ),
                  _filterField(
                    label: 'Date From',
                    child: SizedBox(
                      width: 160,
                      child: _filterDateField(
                        dateFrom,
                        (
                          DateTime date,
                        ) {
                          setState(() {
                            dateFrom = date;
                          });
                        },
                      ),
                    ),
                  ),
                  _filterField(
                    label: 'Date To',
                    child: SizedBox(
                      width: 160,
                      child: _filterDateField(
                        dateTo,
                        (
                          DateTime date,
                        ) {
                          setState(() {
                            dateTo = date;
                          });
                        },
                      ),
                    ),
                  ),
                  GlassButton(
                    onPressed: _loadBills,
                    icon: Icons.filter_alt_outlined,
                    label: 'Filter',
                  ),
                  GlassButton(
                    onPressed: _clearFilters,
                    icon: Icons.refresh,
                    label: 'Clear',
                    primary: false,
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // ERROR
            // ==================================================

            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  14,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFF4E3E3,
                  ),
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(
                        0xFFAB2A2A,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                      ),
                    ),
                    TextButton(
                      onPressed: _loadBills,
                      child: const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],

            // ==================================================
            // TABLE
            // ==================================================

            GlassPanel(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 1200,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.35,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(
                              14,
                            ),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _HeaderText(
                                'DATE',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _HeaderText(
                                'BILL #',
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: _HeaderText(
                                'VENDOR NAME',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _HeaderText(
                                'DUE DATE',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _HeaderText(
                                'STATUS',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _HeaderText(
                                'AMOUNT DUE',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _HeaderText(
                                'TOTAL',
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: _HeaderText(
                                'ACTIONS',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 1,
                        color: Color(
                          0xFFD9DEE5,
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 1200,
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_bills.isEmpty)
                        Container(
                          width: 1200,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 35,
                          ),
                          child: const Text(
                            'No bills found. Click "+ New Bill" to add one!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(
                                0xFF42474D,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._bills.map(
                          (
                            BillModel bill,
                          ) {
                            return Column(
                              children: [
                                Container(
                                  width: 1200,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _fmt(
                                            bill.billDate,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          bill.billNumber,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          bill.vendorName,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _fmt(
                                            bill.dueDate,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusBg(
                                                bill.status,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                20,
                                              ),
                                            ),
                                            child: Text(
                                              bill.status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _statusFg(
                                                  bill.status,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'INR ${bill.amountDue.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'INR ${bill.total.toStringAsFixed(2)}',
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () =>
                                                  _previewBill(bill),
                                              tooltip: 'View bill',
                                              padding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              constraints:
                                                  const BoxConstraints.tightFor(
                                                width: 30,
                                                height: 30,
                                              ),
                                              icon: const Icon(
                                                Icons.visibility_outlined,
                                                color: Color(0xFF7A8490),
                                                size: 19,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: bill.isVoided
                                                  ? null
                                                  : () => _editBill(bill),
                                              tooltip: 'Edit bill',
                                              padding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              constraints:
                                                  const BoxConstraints.tightFor(
                                                width: 30,
                                                height: 30,
                                              ),
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Color(0xFF7A8490),
                                                size: 18,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  _deleteBill(bill),
                                              tooltip: 'Delete bill',
                                              padding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              constraints:
                                                  const BoxConstraints.tightFor(
                                                width: 30,
                                                height: 30,
                                              ),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Color(0xFFAB2A2A),
                                                size: 19,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  color: Color(
                                    0xFFEDEFF2,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
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

  // ==========================================================
  // FILTER FIELD
  // ==========================================================

  Widget _filterField({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(
              0xFF5B5B5B,
            ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        child,
      ],
    );
  }

  // ==========================================================
  // FILTER TEXT
  // ==========================================================

  Widget _filterTextField(
    TextEditingController controller,
    String hint,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(
          0xFFF8F9FA,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            7,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            7,
          ),
          borderSide: const BorderSide(
            color: Color(
              0xFFD9DEE5,
            ),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            7,
          ),
          borderSide: const BorderSide(
            color: Color(
              0xFF123456,
            ),
            width: 2,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FILTER DATE
  // ==========================================================

  Widget _filterDateField(
    DateTime? value,
    ValueChanged<DateTime> onPicked,
  ) {
    return GestureDetector(
      onTap: () {
        _pickDate(
          value,
          onPicked,
        );
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(
            0xFFF8F9FA,
          ),
          borderRadius: BorderRadius.circular(
            7,
          ),
          border: Border.all(
            color: const Color(
              0xFFD9DEE5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? 'dd-mm-yyyy'
                    : _fmt(
                        value,
                      ),
                style: TextStyle(
                  color: value == null ? Colors.grey : Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: Color(
                0xFF888888,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _BillPaymentDetails {
  const _BillPaymentDetails({
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    required this.reference,
  });

  final double amount;
  final DateTime paymentDate;
  final String paymentMode;
  final String reference;
}

class _BillPaymentDialog extends StatefulWidget {
  const _BillPaymentDialog({required this.bill});

  final BillModel bill;

  @override
  State<_BillPaymentDialog> createState() => _BillPaymentDialogState();
}

class _BillPaymentDialogState extends State<_BillPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController =
      TextEditingController(text: widget.bill.amountDue.toStringAsFixed(2));
  late final TextEditingController _referenceController =
      TextEditingController();
  late DateTime _paymentDate = DateTime.now();
  late final TextEditingController _paymentDateController =
      TextEditingController(
          text: DateFormat('dd-MM-yyyy').format(_paymentDate));
  String _paymentMode = 'Bank Transfer';

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _paymentDateController.dispose();
    super.dispose();
  }

  Future<void> _pickPaymentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _paymentDate = picked;
        _paymentDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _BillPaymentDetails(
        amount: double.parse(_amountController.text.trim()),
        paymentDate: _paymentDate,
        paymentMode: _paymentMode,
        reference: _referenceController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: screenSize.height - 32,
        ),
        child: SizedBox(
          width: screenSize.width - 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 12, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Record Payment for ${widget.bill.billNumber}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123456),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final contentWidth = constraints.maxWidth - 48;
                    final fieldWidth = contentWidth > 600
                        ? (contentWidth - 20) / 2
                        : contentWidth;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 18,
                          children: [
                            SizedBox(
                              width: contentWidth,
                              child: DropdownButtonFormField<String>(
                                initialValue: widget.bill.billNumber,
                                decoration: const InputDecoration(
                                  labelText: 'Bill # *',
                                  border: OutlineInputBorder(),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: widget.bill.billNumber,
                                    child: Text(
                                      '${widget.bill.billNumber} '
                                      '(${widget.bill.vendorName}) - '
                                      'Due: INR${widget.bill.amountDue.toStringAsFixed(2)}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                onChanged: (_) {},
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                key: const ValueKey('payment-vendor'),
                                initialValue: widget.bill.vendorName,
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Vendor',
                                  filled: true,
                                  fillColor: Color(0xFFF0F0F0),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                key: const ValueKey('payment-amount-due'),
                                initialValue:
                                    'INR${widget.bill.amountDue.toStringAsFixed(2)}',
                                readOnly: true,
                                decoration: const InputDecoration(
                                  labelText: 'Amount Due',
                                  filled: true,
                                  fillColor: Color(0xFFF0F0F0),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                key: const ValueKey('payment-date'),
                                readOnly: true,
                                onTap: _pickPaymentDate,
                                decoration: InputDecoration(
                                  labelText: 'Payment Date *',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    tooltip: 'Choose payment date',
                                    onPressed: _pickPaymentDate,
                                    icon: const Icon(
                                      Icons.calendar_month_outlined,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                controller: _paymentDateController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                key: const ValueKey('payment-amount'),
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Amount Paid *',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  final amount =
                                      double.tryParse(value?.trim() ?? '');
                                  if (amount == null || amount <= 0) {
                                    return 'Enter an amount greater than zero';
                                  }
                                  if (amount > widget.bill.amountDue) {
                                    return 'Amount cannot exceed the amount due';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: DropdownButtonFormField<String>(
                                initialValue: _paymentMode,
                                decoration: const InputDecoration(
                                  labelText: 'Payment Mode *',
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
                                      (mode) => DropdownMenuItem(
                                        value: mode,
                                        child: Text(mode),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (mode) {
                                  if (mode != null) {
                                    setState(() => _paymentMode = mode);
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: TextFormField(
                                key: const ValueKey('payment-reference'),
                                controller: _referenceController,
                                decoration: const InputDecoration(
                                  labelText: 'Reference #',
                                  hintText: 'e.g., Cheque or TXN ID',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _save,
                      child: const Text('Save Payment'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillPreviewDialog extends StatefulWidget {
  const _BillPreviewDialog({
    required this.bill,
    required this.onDownloadPdf,
    required this.onRecordPayment,
    required this.onVoidBill,
  });

  final BillModel bill;
  final Future<void> Function(BillModel) onDownloadPdf;
  final Future<BillModel?> Function(BillModel) onRecordPayment;
  final Future<BillModel?> Function(BillModel) onVoidBill;

  @override
  State<_BillPreviewDialog> createState() => _BillPreviewDialogState();
}

class _BillPreviewDialogState extends State<_BillPreviewDialog> {
  late BillModel _bill = widget.bill;
  bool _isBusy = false;

  Future<void> _recordPayment() async {
    setState(() => _isBusy = true);
    try {
      final updated = await widget.onRecordPayment(_bill);
      if (mounted && updated != null) {
        setState(() => _bill = updated);
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _downloadPdf() async {
    setState(() => _isBusy = true);
    try {
      await widget.onDownloadPdf(_bill);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _voidBill() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Void bill?'),
        content: Text(
          'This will mark ${_bill.billNumber} as void. '
          'The bill will remain in Bills for record keeping, and no further '
          'payments can be recorded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF849394),
            ),
            child: const Text('Void'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final updated = await widget.onVoidBill(_bill);
      if (mounted && updated != null) setState(() => _bill = updated);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String _currency(double amount) =>
      'INR ${NumberFormat('#,##0.00', 'en_IN').format(amount)}';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final narrow = screenSize.width < 900;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: SizedBox(
        width: screenSize.width < 1100 ? screenSize.width - 32 : 1000,
        height: screenSize.height < 650
            ? screenSize.height - 32
            : screenSize.height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 14, 18),
              child: narrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBillHeading(),
                        const SizedBox(height: 12),
                        _buildActions(),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _buildBillHeading()),
                        _buildActions(),
                      ],
                    ),
            ),
            const Divider(height: 1, color: Color(0xFFE1E4E8)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 20, 20),
                child: narrow
                    ? Column(
                        children: [
                          Expanded(child: _buildItemsTable()),
                          const SizedBox(height: 20),
                          _buildSummary(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 7, child: _buildItemsTable()),
                          const SizedBox(width: 26),
                          const VerticalDivider(
                            width: 1,
                            color: Color(0xFFD9DEE5),
                          ),
                          const SizedBox(width: 26),
                          Expanded(flex: 4, child: _buildSummary()),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _bill.vendorName,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF123456),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_bill.billNumber} | '
          '${DateFormat('d/M/yyyy').format(_bill.billDate)}',
          style: const TextStyle(color: Color(0xFF6B6B6B)),
        ),
        Text(
          'Vendor Invoice #: '
          '${_bill.vendorInvoiceNumber.isEmpty ? 'N/A' : _bill.vendorInvoiceNumber}',
          style: const TextStyle(color: Color(0xFF6B6B6B)),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: _isBusy || _bill.amountDue <= 0 || _bill.isVoided
              ? null
              : _recordPayment,
          icon: const Icon(Icons.credit_card, size: 17),
          label: const Text('Record Payment'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
            foregroundColor: Colors.white,
          ),
        ),
        FilledButton.icon(
          onPressed: _isBusy ? null : _downloadPdf,
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 17),
          label: const Text('Download PDF'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2980B9),
            foregroundColor: Colors.white,
          ),
        ),
        FilledButton(
          onPressed: _isBusy || _bill.isVoided ? null : _voidBill,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF849394),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF849394),
            disabledForegroundColor: Colors.white,
          ),
          child: Text(_bill.isVoided ? 'Voided' : 'Void'),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
          icon: const Icon(Icons.close, color: Color(0xFF8A8A8A)),
        ),
      ],
    );
  }

  Widget _buildItemsTable() {
    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2.5),
          1: FlexColumnWidth(1.1),
          2: FlexColumnWidth(1.7),
          3: FlexColumnWidth(1.7),
        },
        border: const TableBorder(
          horizontalInside: BorderSide(color: Color(0xFFD9DEE5)),
          bottom: BorderSide(color: Color(0xFFD9DEE5)),
        ),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFFF5F6F7)),
            children: [
              _BillPreviewCell('Item & Description', header: true),
              _BillPreviewCell('Qty', header: true),
              _BillPreviewCell('Rate', header: true),
              _BillPreviewCell('Amount', header: true),
            ],
          ),
          ..._bill.items.map(
            (item) => TableRow(
              children: [
                _BillPreviewCell(
                  item.description.trim().isEmpty
                      ? item.itemName
                      : '${item.itemName}\n${item.description.trim()}',
                ),
                _BillPreviewCell(item.qty.toStringAsFixed(2)),
                _BillPreviewCell(_currency(item.rate)),
                _BillPreviewCell(_currency(item.amount)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 18),
          _BillSummaryLine(
            label: 'Sub Total',
            value: _currency(_bill.subTotal),
          ),
          const SizedBox(height: 18),
          _BillSummaryLine(
            label: 'Tax',
            value: _currency(_bill.taxAmount),
          ),
          const SizedBox(height: 18),
          _BillSummaryLine(
            label: 'Total',
            value: _currency(_bill.total),
            emphasized: true,
          ),
          const SizedBox(height: 22),
          _BillSummaryLine(
            label: 'Amount Paid',
            value: _currency(_bill.amountPaid),
            valueColor: const Color(0xFF1EBD63),
          ),
          const SizedBox(height: 22),
          _BillSummaryLine(
            label: 'Amount Due',
            value: _currency(_bill.amountDue),
            emphasized: true,
            valueColor: const Color(0xFFEF5145),
          ),
          if (_bill.dueDate != null) ...[
            const SizedBox(height: 18),
            _BillSummaryLine(
              label: 'Due Date',
              value: DateFormat('dd MMM yyyy').format(_bill.dueDate!),
            ),
          ],
          const SizedBox(height: 22),
          const Text(
            'Attachment',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _bill.invoiceAttachmentPath?.isNotEmpty == true
                ? _bill.invoiceAttachmentPath!
                : 'No attachment.',
            style: const TextStyle(color: Color(0xFF555555)),
          ),
        ],
      ),
    );
  }
}

class _BillPreviewCell extends StatelessWidget {
  const _BillPreviewCell(this.text, {this.header = false});

  final String text;
  final bool header;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF333333),
          fontSize: header ? 14 : 13,
          fontWeight: header ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _BillSummaryLine extends StatelessWidget {
  const _BillSummaryLine({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasized;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: emphasized ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: emphasized ? 17 : 14,
            fontWeight: emphasized ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;

  const _HeaderText(
    this.text,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(
          0xFF5B5B5B,
        ),
      ),
    );
  }
}
