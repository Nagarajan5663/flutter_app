import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../shared/glass_modal_shell.dart';
import '../bills/bill_filter.dart';
import '../bills/bill_model.dart';
import '../bills/bill_repository.dart';
import '../bills/widgets/add_bill_dialog.dart';
import '../purchase_orders/purchase_order_model.dart';
import '../purchase_orders/purchase_order_filter.dart';
import '../purchase_orders/purchase_order_repository.dart';
import '../purchase_orders/widgets/add_purchase_order_dialog.dart';
import 'vendor_comment_model.dart';
import 'vendor_model.dart';
import 'vendor_repository.dart';

class VendorDetailsPage extends StatefulWidget {
  const VendorDetailsPage({
    super.key,
    required this.vendor,
    required this.repository,
    required this.authorName,
  });

  final VendorModel vendor;
  final VendorRepository repository;
  final String authorName;

  @override
  State<VendorDetailsPage> createState() => _VendorDetailsPageState();
}

class _VendorDetailsPageState extends State<VendorDetailsPage> {
  final BillRepository _billRepository = ApiBillRepository();
  final PurchaseOrderRepository _purchaseOrderRepository =
      ApiPurchaseOrderRepository();
  final TextEditingController _commentController = TextEditingController();

  late Future<VendorModel> _vendorFuture;
  late Future<_PayablesSummary> _payablesFuture;
  late Future<List<VendorComment>> _commentsFuture;
  late Future<_VendorTransactions> _transactionsFuture;
  late DateTime _statementStartDate;
  late DateTime _statementEndDate;
  bool _isSavingComment = false;
  bool _isGeneratingStatement = false;
  String? _statementError;

  @override
  void initState() {
    super.initState();
    _vendorFuture = _loadVendor();
    _payablesFuture = _loadPayables();
    _commentsFuture = _loadComments();
    _transactionsFuture = _loadTransactions();
    _statementEndDate = DateUtils.dateOnly(DateTime.now());
    _statementStartDate = DateTime(
      _statementEndDate.year - 1,
      _statementEndDate.month,
      _statementEndDate.day,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<VendorModel> _loadVendor() {
    final id = widget.vendor.id;
    if (id == null || id.trim().isEmpty) {
      return Future<VendorModel>.value(widget.vendor);
    }
    return widget.repository.getVendorById(id);
  }

  void _refresh() {
    setState(() {
      _vendorFuture = _loadVendor();
      _payablesFuture = _loadPayables();
      _commentsFuture = _loadComments();
      _transactionsFuture = _loadTransactions();
    });
  }

  Future<List<VendorComment>> _loadComments() {
    final vendorId = widget.vendor.id;
    if (vendorId == null || vendorId.trim().isEmpty) {
      return Future<List<VendorComment>>.error(
        StateError('Cannot load comments for a vendor without an ID.'),
      );
    }
    return widget.repository.getVendorComments(vendorId);
  }

  Future<_VendorTransactions> _loadTransactions() async {
    final vendorId = widget.vendor.id;
    if (vendorId == null || vendorId.trim().isEmpty) {
      throw StateError('Cannot load transactions for a vendor without an ID.');
    }
    final purchaseOrders = await _purchaseOrderRepository.getPurchaseOrders(
      filter: PurchaseOrderFilter(vendorId: vendorId),
    );
    final bills = await _billRepository.getBills(
      filter: BillFilter(vendorId: vendorId),
    );
    return _VendorTransactions(
      purchaseOrders: purchaseOrders,
      bills: bills,
    );
  }

  Future<void> _saveComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty || _isSavingComment) return;

    final vendorId = widget.vendor.id;
    if (vendorId == null || vendorId.trim().isEmpty) {
      _showActionError('save comment', StateError('Vendor ID is missing.'));
      return;
    }

    setState(() => _isSavingComment = true);
    try {
      await widget.repository.addVendorComment(
        vendorId,
        widget.authorName,
        comment,
      );
      if (!mounted) return;
      _commentController.clear();
      setState(() {
        _isSavingComment = false;
        _commentsFuture = _loadComments();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment saved successfully')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSavingComment = false);
      _showActionError('save comment', error);
    }
  }

  Future<_PayablesSummary> _loadPayables() async {
    final vendorId = widget.vendor.id;
    if (vendorId == null || vendorId.trim().isEmpty) {
      return const _PayablesSummary.zero();
    }

    final bills = await _billRepository.getBills(
      filter: BillFilter(vendorId: vendorId),
    );
    final today = DateUtils.dateOnly(DateTime.now());
    var overdue = 0.0;
    var notDue = 0.0;
    for (final bill in bills.where((bill) => bill.vendorId == vendorId)) {
      if (bill.amountDue <= 0) continue;
      final dueDate = bill.dueDate;
      if (dueDate != null && DateUtils.dateOnly(dueDate).isBefore(today)) {
        overdue += bill.amountDue;
      } else {
        notDue += bill.amountDue;
      }
    }
    return _PayablesSummary(overdue: overdue, notDue: notDue);
  }

  Future<void> _openNewPurchaseOrder() async {
    final order = await showDialog<PurchaseOrderModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddPurchaseOrderDialog(initialVendor: widget.vendor),
    );
    if (!mounted || order == null) return;

    try {
      await _purchaseOrderRepository.addPurchaseOrder(order);
      if (!mounted) return;
      setState(() {
        _transactionsFuture = _loadTransactions();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase order created successfully'),
        ),
      );
    } catch (error) {
      _showActionError('create purchase order', error);
    }
  }

  Future<void> _openNewBill() async {
    final draft = await showDialog<BillModelDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddBillDialog(initialVendor: widget.vendor),
    );
    if (!mounted || draft == null) return;

    final bill = BillModel(
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
      await _billRepository.addBill(bill);
      if (!mounted) return;
      setState(() {
        _payablesFuture = _loadPayables();
        _transactionsFuture = _loadTransactions();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill created successfully')),
      );
    } catch (error) {
      _showActionError('create bill', error);
    }
  }

  void _showActionError(String action, Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to $action: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = screenSize.width < 932 ? screenSize.width - 32 : 900.0;
    final dialogHeight =
        screenSize.height < 602 ? screenSize.height - 32 : 570.0;

    return DefaultTabController(
      length: 5,
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: Column(
            children: [
              Container(
                height: 82,
                padding: const EdgeInsets.only(left: 24, right: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFD9DEE5)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.vendor.vendorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123456),
                        ),
                      ),
                    ),
                    _headerAction(
                      label: 'New Purchase Order',
                      onPressed: _openNewPurchaseOrder,
                    ),
                    const SizedBox(width: 8),
                    _headerAction(
                      label: 'New Bill',
                      onPressed: _openNewBill,
                    ),
                    IconButton(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh vendor details',
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<VendorModel>(
                  future: _vendorFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return _buildLoadError(snapshot.error.toString());
                    }
                    final vendor = snapshot.data;
                    if (vendor == null) {
                      return _buildLoadError(
                        'The vendor details were not returned.',
                      );
                    }
                    return _buildDetails(vendor);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerAction({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD1D1D1),
          foregroundColor: const Color(0xFF252A31),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadError(String error) {
    return Center(
      child: GlassPanel(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFAB2A2A), size: 36),
            const SizedBox(height: 12),
            const Text(
              'Unable to load vendor details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SelectableText(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails(VendorModel vendor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.white,
          child: TabBar(
            isScrollable: false,
            labelColor: const Color(0xFF1687D9),
            unselectedLabelColor: const Color(0xFF42474D),
            indicatorColor: const Color(0xFF1687D9),
            tabs: const [
              Tab(text: 'Business Overview'),
              Tab(text: 'Address'),
              Tab(text: 'Comments'),
              Tab(text: 'Transactions'),
              Tab(text: 'Statement'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              _buildOverview(vendor),
              _buildAddresses(vendor),
              _buildComments(),
              _buildTransactions(),
              _buildStatement(vendor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatement(VendorModel vendor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate Vendor Statement (PDF/HTML)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF252A31),
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final controls = Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  _statementDateField(
                    label: 'Start Date',
                    date: _statementStartDate,
                    onSelected: (date) => setState(() {
                      _statementStartDate = date;
                      _statementError = null;
                    }),
                  ),
                  _statementDateField(
                    label: 'End Date',
                    date: _statementEndDate,
                    onSelected: (date) => setState(() {
                      _statementEndDate = date;
                      _statementError = null;
                    }),
                  ),
                  FilledButton.icon(
                    onPressed:
                        _isGeneratingStatement ? null : _generateStatement,
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: Text(
                      _isGeneratingStatement
                          ? 'Generating...'
                          : 'Generate Statement',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF3498DB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              );
              return controls;
            },
          ),
          if (_isGeneratingStatement) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (_statementError != null) ...[
            const SizedBox(height: 12),
            Text(
              _statementError!,
              style: const TextStyle(
                color: Color(0xFFAB2A2A),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Text(
            'Generate a printable statement using bills recorded for this vendor during the selected period.',
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF252A31),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statementDateField({
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onSelected,
  }) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selected != null) onSelected(DateUtils.dateOnly(selected));
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF123456),
              side: const BorderSide(color: Color(0xFFD9DEE5)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('dd-MM-yyyy').format(date),
                    textAlign: TextAlign.left,
                  ),
                ),
                const Icon(Icons.calendar_month_outlined, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateStatement() async {
    if (_isGeneratingStatement) return;
    if (_statementStartDate.isAfter(_statementEndDate)) {
      setState(() {
        _statementError = 'Start date must be on or before the end date.';
      });
      return;
    }

    setState(() {
      _isGeneratingStatement = true;
      _statementError = null;
    });
    try {
      final vendorId = widget.vendor.id;
      if (vendorId == null || vendorId.trim().isEmpty) {
        throw StateError(
            'Cannot generate a statement for a vendor without an ID.');
      }
      final bills = await _billRepository.getBills(
        filter: BillFilter(vendorId: vendorId),
      );
      if (!mounted) return;
      final statement = _VendorStatement.fromBills(
        vendor: await _vendorFuture,
        bills: bills.where((bill) => bill.vendorId == vendorId).toList(),
        startDate: _statementStartDate,
        endDate: _statementEndDate,
        reportDate: DateUtils.dateOnly(DateTime.now()),
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        builder: (_) => _VendorStatementPreview(
          statement: statement,
          onPrint: () => _printStatement(statement),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _statementError = 'Unable to generate statement: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingStatement = false);
      }
    }
  }

  Future<void> _printStatement(_VendorStatement statement) async {
    try {
      final document = _buildStatementPdf(statement);
      await Printing.layoutPdf(
        name: 'vendor-statement-${statement.vendor.vendorName}.pdf',
        onLayout: (_) => document.save(),
      );
    } catch (error) {
      _showActionError('print statement', error);
    }
  }

  pw.Document _buildStatementPdf(_VendorStatement statement) {
    final document = pw.Document();
    final currency = NumberFormat('#,##0.00', 'en_IN');
    String money(double amount) => 'INR ${currency.format(amount)}';
    final rows = <List<String>>[
      [
        '',
        '',
        'Opening Balance (Bills)',
        '',
        '',
        money(statement.openingBalance)
      ],
      ...statement.entries.map(
        (entry) => [
          DateFormat('dd MMM yyyy').format(entry.bill.billDate),
          'Bill',
          entry.bill.billNumber,
          '-',
          money(entry.bill.total),
          money(entry.balance),
        ],
      ),
      ['', 'Period Totals', '', '-', money(statement.periodBillTotal), ''],
      [
        '',
        '',
        'Closing Balance (Bills only)',
        '',
        '',
        money(statement.closingBalance)
      ],
    ];

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            'Vendor Statement',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#123456'),
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Statement For:'),
                  pw.Text(
                    statement.vendor.vendorName,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  if (statement.vendor.email.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 8),
                      child: pw.Text(statement.vendor.email),
                    ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Report Date: ${DateFormat('dd MMM yyyy').format(statement.reportDate)}',
                  ),
                  pw.Text('Currency: INR'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            color: PdfColor.fromHex('#EEEEEE'),
            padding: const pw.EdgeInsets.all(10),
            child: pw.Text(
              'Statement Period: ${DateFormat('dd MMM yyyy').format(statement.startDate)} to ${DateFormat('dd MMM yyyy').format(statement.endDate)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Date',
              'Type',
              'Document #',
              'Debits',
              'Credits',
              'Balance',
            ],
            data: rows,
            headerDecoration:
                pw.BoxDecoration(color: PdfColor.fromHex('#123456')),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellPadding: const pw.EdgeInsets.all(6),
            border: pw.TableBorder.all(
              color: PdfColor.fromHex('#D9DEE5'),
              width: 0.5,
            ),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'This statement includes bills recorded for this vendor. Dated payment and vendor-credit transactions are not available in the current records and are not included or deducted; balances are bill-based.',
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 20),
          pw.Center(
            child: pw.Text(
              'Automatically generated Vendor Statement',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
    return document;
  }

  Widget _buildTransactions() {
    return FutureBuilder<_VendorTransactions>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unable to load vendor transactions: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFAB2A2A)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => setState(
                        () => _transactionsFuture = _loadTransactions()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        final transactions = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _transactionSection(
                title: 'Purchase Orders',
                headers: const ['Date', 'PO Number', 'Amount', 'Status'],
                rows: transactions.purchaseOrders
                    .map(
                      (order) => [
                        _formatTransactionDate(order.date),
                        order.poNumber,
                        _formatAmount(order.total),
                        order.status,
                      ],
                    )
                    .toList(),
                emptyMessage: 'No purchase orders found.',
              ),
              const SizedBox(height: 20),
              _transactionSection(
                title: 'Bills',
                headers: const ['Date', 'Bill Number', 'Amount', 'Status'],
                rows: transactions.bills
                    .map(
                      (bill) => [
                        _formatTransactionDate(bill.billDate),
                        bill.billNumber,
                        _formatAmount(bill.total),
                        bill.status,
                      ],
                    )
                    .toList(),
                emptyMessage: 'No bills found.',
              ),
              const SizedBox(height: 20),
              _transactionSection(
                title: 'Payments Made',
                headers: const [
                  'Date',
                  'Bill Number',
                  'Payment Mode',
                  'Amount Paid',
                ],
                rows: const [],
                emptyMessage: 'No payments found.',
              ),
              const SizedBox(height: 20),
              _transactionSection(
                title: 'Vendor Credits',
                headers: const ['Date', 'Credit Note #', 'Amount', 'Status'],
                rows: const [],
                emptyMessage: 'No vendor credits found.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _transactionSection({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF123456),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD9DEE5)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              Container(
                color: const Color(0xFFF8F9FA),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: headers
                      .map(
                        (header) => Expanded(
                          child: Text(
                            header,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF252A31),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFD9DEE5)),
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      emptyMessage,
                      style: const TextStyle(
                        color: Color(0xFF7A8490),
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ...rows.map(
                  (row) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: row
                              .map(
                                (value) => Expanded(
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Color(0xFF252A31),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      if (row != rows.last)
                        const Divider(
                          height: 1,
                          color: Color(0xFFEDEFF2),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTransactionDate(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  String _formatAmount(double amount) => '₹${amount.toStringAsFixed(2)}';

  Widget _buildComments() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Internal Comments',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF252A31),
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _commentController,
            minLines: 3,
            maxLines: 4,
            maxLength: 2000,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Type your internal note here...',
              hintStyle: const TextStyle(
                color: Color(0xFF7A8490),
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.all(10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
              ),
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _isSavingComment ? null : _saveComment,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: _isSavingComment
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Comment',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFD9DEE5)),
          Expanded(
            child: FutureBuilder<List<VendorComment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load comments: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFAB2A2A)),
                    ),
                  );
                }

                final comments = snapshot.data ?? const <VendorComment>[];
                if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'No comments yet.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7A8490),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(top: 12),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _commentEntry(comment);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentEntry(VendorComment comment) {
    final initials = comment.authorName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final timestamp = comment.createdAt == null
        ? ''
        : DateFormat('MMM d, yyyy, hh:mm a')
            .format(comment.createdAt!.toLocal());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF123456),
            foregroundColor: Colors.white,
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        comment.authorName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF252A31),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      timestamp,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A8490),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.comment,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF252A31),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(VendorModel vendor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contactDetails = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _overviewField('Primary Contact', _primaryContact(vendor)),
            _overviewField('Company Name', vendor.companyName),
            _overviewField('Vendor Email', vendor.email),
            _overviewField('Vendor Phone', vendor.phone),
            _overviewField('Website', vendor.website),
            _overviewField('Vendor Type', vendor.vendorType),
            _overviewField('GST Applicable', vendor.gstApplicable),
            _overviewField('GST Number', ''),
            const SizedBox(height: 8),
            const Text(
              'Payment History (Last 6 Months)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B5B5B),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No payment history for the last 6 months.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF252A31),
              ),
            ),
          ],
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: constraints.maxWidth < 650
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPayablesCard(),
                    const SizedBox(height: 20),
                    contactDetails,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: contactDetails),
                    const SizedBox(width: 24),
                    Expanded(flex: 4, child: _buildPayablesCard()),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPayablesCard() {
    return FutureBuilder<_PayablesSummary>(
      future: _payablesFuture,
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            border: Border.all(color: const Color(0xFFD9DEE5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: snapshot.connectionState == ConnectionState.waiting
              ? const SizedBox(
                  height: 55,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : snapshot.hasError
                  ? Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFAB2A2A)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Unable to load payables: ${snapshot.error}',
                            style: const TextStyle(
                              color: Color(0xFFAB2A2A),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            _payablesFuture = _loadPayables();
                          }),
                          icon: const Icon(Icons.refresh, size: 18),
                          tooltip: 'Retry loading payables',
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _payableAmount(
                            'Overdue Payables',
                            snapshot.data!.overdue,
                            const Color(0xFFE53935),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _payableAmount(
                            'Payables Not Due',
                            snapshot.data!.notDue,
                            const Color(0xFF18B85A),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _payableAmount(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7A8490),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _overviewField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7A8490),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _displayValue(value),
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF123456),
            ),
          ),
        ],
      ),
    );
  }

  String _primaryContact(VendorModel vendor) {
    final name = [vendor.firstName, vendor.lastName]
        .where((part) => part.trim().isNotEmpty)
        .join(' ');
    if (name.isEmpty) return vendor.vendorName;
    return '${vendor.salutation} $name';
  }

  Widget _buildAddresses(VendorModel vendor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          _detailSection(
            title: 'Billing Address',
            icon: Icons.receipt_long_outlined,
            rows: [
              _DetailRow('Street', vendor.billingStreet),
              _DetailRow('City', vendor.city),
              _DetailRow('State', vendor.state),
              _DetailRow('Zip code', vendor.billingZip),
              _DetailRow('Country', vendor.country),
            ],
          ),
          const SizedBox(height: 16),
          _detailSection(
            title: 'Shipping Address',
            icon: Icons.local_shipping_outlined,
            rows: vendor.shippingSameAsBilling
                ? const [_DetailRow('Address', 'Same as billing address')]
                : [
                    _DetailRow('Street', vendor.shippingStreet),
                    _DetailRow('City', vendor.shippingCity),
                    _DetailRow('State', vendor.shippingState),
                    _DetailRow('Zip code', vendor.shippingZip),
                    _DetailRow('Country', vendor.shippingCountry),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _detailSection({
    required String title,
    required IconData icon,
    required List<_DetailRow> rows,
  }) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF123456)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF123456),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 6),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    child: Text(
                      row.label,
                      style: const TextStyle(
                        color: Color(0xFF5B5B5B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _displayValue(row.value),
                      style: const TextStyle(color: Color(0xFF252A31)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayValue(String value) => value.trim().isEmpty ? '—' : value;
}

class _DetailRow {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;
}

class _PayablesSummary {
  const _PayablesSummary({
    required this.overdue,
    required this.notDue,
  });

  const _PayablesSummary.zero()
      : overdue = 0,
        notDue = 0;

  final double overdue;
  final double notDue;
}

class _VendorTransactions {
  const _VendorTransactions({
    required this.purchaseOrders,
    required this.bills,
  });

  final List<PurchaseOrderModel> purchaseOrders;
  final List<BillModel> bills;
}

class _VendorStatement {
  const _VendorStatement({
    required this.vendor,
    required this.startDate,
    required this.endDate,
    required this.reportDate,
    required this.openingBalance,
    required this.entries,
    required this.periodBillTotal,
    required this.closingBalance,
  });

  factory _VendorStatement.fromBills({
    required VendorModel vendor,
    required List<BillModel> bills,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime reportDate,
  }) {
    final start = DateUtils.dateOnly(startDate);
    final endExclusive =
        DateUtils.dateOnly(endDate).add(const Duration(days: 1));
    final vendorBills = bills
        .where((bill) => bill.billDate.isBefore(endExclusive))
        .toList()
      ..sort((a, b) => a.billDate.compareTo(b.billDate));
    final openingBalance = vendorBills
        .where((bill) => bill.billDate.isBefore(start))
        .fold<double>(0, (sum, bill) => sum + bill.total);
    final periodBills = vendorBills
        .where(
          (bill) =>
              !bill.billDate.isBefore(start) &&
              bill.billDate.isBefore(endExclusive),
        )
        .toList();
    final periodBillTotal =
        periodBills.fold<double>(0, (sum, bill) => sum + bill.total);
    var balance = openingBalance;
    final entries = periodBills.map((bill) {
      balance += bill.total;
      return _VendorStatementEntry(bill: bill, balance: balance);
    }).toList();

    return _VendorStatement(
      vendor: vendor,
      startDate: start,
      endDate: DateUtils.dateOnly(endDate),
      reportDate: reportDate,
      openingBalance: openingBalance,
      entries: entries,
      periodBillTotal: periodBillTotal,
      closingBalance: balance,
    );
  }

  final VendorModel vendor;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime reportDate;
  final double openingBalance;
  final List<_VendorStatementEntry> entries;
  final double periodBillTotal;
  final double closingBalance;
}

class _VendorStatementEntry {
  const _VendorStatementEntry({required this.bill, required this.balance});

  final BillModel bill;
  final double balance;
}

class _VendorStatementPreview extends StatelessWidget {
  const _VendorStatementPreview({
    required this.statement,
    required this.onPrint,
  });

  final _VendorStatement statement;
  final Future<void> Function() onPrint;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final rows = <List<String>>[
      [
        '',
        '',
        'Opening Balance (Bills)',
        '',
        '',
        currency.format(statement.openingBalance),
      ],
      ...statement.entries.map(
        (entry) => [
          DateFormat('dd MMM, yyyy').format(entry.bill.billDate),
          'Bill',
          entry.bill.billNumber,
          '-',
          currency.format(entry.bill.total),
          currency.format(entry.balance),
        ],
      ),
      [
        '',
        'Period Totals:',
        '',
        '-',
        currency.format(statement.periodBillTotal),
        '',
      ],
      [
        '',
        '',
        'Closing Balance (Bills only) as of ${DateFormat('dd MMM, yyyy').format(statement.endDate)}',
        '',
        '',
        currency.format(statement.closingBalance),
      ],
    ];
    const headers = [
      'Date',
      'Type',
      'Document #',
      'Debits (Payment/Credit Note)',
      'Credits (Bill/Liability)',
      'Balance',
    ];

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: screenSize.width < 980 ? screenSize.width - 32 : 900,
        height: screenSize.height < 760 ? screenSize.height - 32 : 650,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 12, 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFD9DEE5)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vendor Statement: ${statement.vendor.vendorName}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Statement For:'),
                              Text(
                                statement.vendor.vendorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (statement.vendor.email.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(statement.vendor.email),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Report Date: ${DateFormat('dd MMM, yyyy').format(statement.reportDate)}',
                            ),
                            const Text('Currency: INR'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Statement Period: ${DateFormat('dd MMM, yyyy').format(statement.startDate)} to ${DateFormat('dd MMM, yyyy').format(statement.endDate)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFF123456),
                        ),
                        headingTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        dataTextStyle: const TextStyle(
                          color: Color(0xFF252A31),
                          fontSize: 12,
                        ),
                        border: TableBorder.all(
                          color: const Color(0xFFD9DEE5),
                          width: 0.7,
                        ),
                        columnSpacing: 18,
                        horizontalMargin: 10,
                        columns: headers
                            .map((header) => DataColumn(label: Text(header)))
                            .toList(),
                        rows: rows.map((row) {
                          final isSummary = row[1].contains('Totals') ||
                              row[2].startsWith('Opening') ||
                              row[2].startsWith('Closing');
                          return DataRow(
                            color: isSummary
                                ? WidgetStateProperty.all(
                                    const Color(0xFFE3F4FC),
                                  )
                                : null,
                            cells: row
                                .map((value) => DataCell(Text(value)))
                                .toList(),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'This statement includes bills recorded for this vendor. Dated payment and vendor-credit transactions are not available in the current records and are not included or deducted; balances are bill-based.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5B5B5B),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        'This is an automatically generated Vendor Statement.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5B5B5B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: OutlinedButton.icon(
                onPressed: onPrint,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print / Save as PDF'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
