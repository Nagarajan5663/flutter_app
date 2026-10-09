import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/sales_glass_widgets.dart';

import '../widgets/sales_dialog_helpers.dart';
import 'delivery_challan_filter.dart';
import 'delivery_challan_model.dart';
import 'delivery_challan_repository.dart';
import 'widgets/add_delivery_challan_dialog.dart';
import 'widgets/delivery_challan_preview_dialog.dart';

class DeliveryChallansPage extends StatefulWidget {
  const DeliveryChallansPage({super.key});

  @override
  State<DeliveryChallansPage> createState() => _DeliveryChallansPageState();
}

class _DeliveryChallansPageState extends State<DeliveryChallansPage> {
  final DeliveryChallanRepository _repository =
      InMemoryDeliveryChallanRepository();

  List<DeliveryChallanModel> _challans = [];
  bool _isLoading = true;
  String? _loadError;
  int _rowsPerPage = 25;
  int _currentPage = 0;

  final customerController = TextEditingController();
  DateTime? dateFrom;
  DateTime? dateTo;

  @override
  void initState() {
    super.initState();
    _loadChallans();
  }

  @override
  void dispose() {
    customerController.dispose();
    super.dispose();
  }

  DeliveryChallanFilter get _currentFilter => DeliveryChallanFilter(
        customerName: customerController.text,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

  Future<void> _loadChallans() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    late final List<DeliveryChallanModel> result;
    try {
      result = await _repository.getChallans(filter: _currentFilter);
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
      _challans = result;
      _isLoading = false;
      _currentPage = _currentPage.clamp(0, _pageCount - 1);
    });
  }

  int get _pageCount =>
      _challans.isEmpty ? 1 : (_challans.length / _rowsPerPage).ceil();

  List<DeliveryChallanModel> get _visibleChallans {
    final start = _currentPage * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, _challans.length);
    return _challans.sublist(start.clamp(0, _challans.length), end);
  }

  Widget _paginationControls() {
    final pageCount = _pageCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text('Show:'),
          const SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _rowsPerPage,
              dropdownColor: Colors.white,
              items: const [10, 25, 50, 100]
                  .map((size) => DropdownMenuItem(
                        value: size,
                        child: Text('$size'),
                      ))
                  .toList(),
              onChanged: (size) {
                if (size == null) return;
                setState(() {
                  _rowsPerPage = size;
                  _currentPage = 0;
                });
              },
            ),
          ),
          const Spacer(),
          Text('Page ${_currentPage + 1} of $pageCount'),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed:
                _currentPage > 0 ? () => setState(() => _currentPage--) : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Prev'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _currentPage + 1 < pageCount
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
            iconAlignment: IconAlignment.end,
          ),
        ],
      ),
    );
  }

  Future<void> _openAddChallan() async {
    final challan = await showDialog<DeliveryChallanModel>(
      context: context,
      barrierColor: const Color(0x9A12202C),
      barrierDismissible: false,
      builder: (_) => const AddDeliveryChallanDialog(),
    );
    if (!mounted || challan == null) return;
    if (challan.id == null) await _repository.addChallan(challan);
    await _loadChallans();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery challan created successfully')));
  }

  Future<void> _deleteChallan(DeliveryChallanModel challan) async {
    if (challan.id == null) return;
    try {
      await _repository.deleteChallan(challan.id!);
      await _loadChallans();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _updateStatus(
      DeliveryChallanModel challan, String status) async {
    if (challan.id == null) return;
    try {
      await _repository.updateStatus(challan.id!, status);
      await _loadChallans();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _viewChallan(DeliveryChallanModel challan) async {
    await showDialog<void>(
      context: context,
      builder: (_) => DeliveryChallanPreviewDialog(
        challan: challan,
        onDownloadPdf: () => _downloadChallanPdf(challan),
        onSendMail: () => _sendChallanMail(challan),
        onVoid: () => _confirmVoidChallan(challan),
      ),
    );
  }

  Future<void> _downloadChallanPdf(DeliveryChallanModel challan) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            'DELIVERY CHALLAN',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Customer: ${challan.customerName}'),
          pw.Text('Challan: ${challan.challanNumber}'),
          pw.Text(
            'Date: ${DateFormat('dd MMM yyyy').format(challan.challanDate)}',
          ),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: const ['Item & Description', 'Qty', 'Rate', 'Amount'],
            data: [
              for (final item in challan.items)
                [
                  [
                    item.itemName,
                    if (item.description.isNotEmpty) item.description,
                  ].join('\n'),
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
                pw.Text('Sub Total: INR ${challan.total.toStringAsFixed(2)}'),
                pw.Text(
                  'Total: INR ${challan.total.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
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
        filename: '${challan.challanNumber}.pdf',
      );
    } catch (error) {
      if (mounted) {
        _showMessage('Unable to create Delivery Challan PDF: $error',
            isError: true);
      }
    }
  }

  Future<void> _sendChallanMail(DeliveryChallanModel challan) async {
    final recipientController = TextEditingController();
    try {
      final recipient = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Send Delivery Challan'),
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

      final subject = 'Delivery Challan ${challan.challanNumber}';
      final body = 'Delivery Challan ${challan.challanNumber} '
          'for ${challan.customerName}. Total: INR '
          '${challan.total.toStringAsFixed(2)}.';
      final mailUri = Uri(
        scheme: 'mailto',
        path: recipient,
        queryParameters: {'subject': subject, 'body': body},
      );
      if (!await launchUrl(mailUri, mode: LaunchMode.externalApplication)) {
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

  Future<void> _confirmVoidChallan(DeliveryChallanModel challan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Void Delivery Challan'),
        content: Text('Void challan ${challan.challanNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Void'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _updateStatus(challan, 'Void');
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

  Future<void> _confirmDeleteChallan(DeliveryChallanModel challan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Delivery Challan'),
        content: Text('Delete challan ${challan.challanNumber}?'),
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
    if (confirmed == true) await _deleteChallan(challan);
  }

  Future<void> _cloneChallan(DeliveryChallanModel challan) async {
    if (challan.id == null) return;
    try {
      final clone = await _repository.cloneChallan(challan.id!);
      await _loadChallans();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Challan ${clone.challanNumber} cloned as Draft.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _editChallan(DeliveryChallanModel challan) async {
    if (challan.id == null) return;
    final transportController =
        TextEditingController(text: challan.transportationDetails);
    DateTime? deliveryDate = challan.deliveryDate;
    var saving = false;
    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Edit ${challan.challanNumber}'),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Delivery date'),
                    subtitle: Text(
                      deliveryDate == null
                          ? 'Not set'
                          : DateFormat('dd MMM yyyy').format(deliveryDate!),
                    ),
                    trailing: IconButton(
                      tooltip: 'Choose delivery date',
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: deliveryDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setDialogState(() => deliveryDate = date);
                        }
                      },
                    ),
                  ),
                  TextField(
                    controller: transportController,
                    decoration: const InputDecoration(
                      labelText: 'Transportation details',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
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
                        setDialogState(() => saving = true);
                        try {
                          await _repository.updateDetails(
                            challan.id!,
                            deliveryDate: deliveryDate,
                            transportationDetails:
                                transportController.text.trim(),
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext, true);
                          }
                        } catch (error) {
                          setDialogState(() => saving = false);
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(error
                                    .toString()
                                    .replaceFirst('Exception: ', '')),
                              ),
                            );
                          }
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
      if (saved == true && mounted) await _loadChallans();
    } finally {
      transportController.dispose();
    }
  }

  void _clearFilters() {
    customerController.clear();
    dateFrom = null;
    dateTo = null;
    _loadChallans();
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
                  child: Text('Delivery Challans',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF123456))),
                ),
                ElevatedButton.icon(
                  onPressed: _openAddChallan,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Challan'),
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
                    onPressed: _loadChallans,
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
                          _paginationControls(),
                          Container(
                            width: tableWidth,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(14)),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      const SalesHeaderText('DATE'),
                                      const Icon(Icons.arrow_drop_down,
                                          size: 18),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child: SalesHeaderText('CHALLAN #')),
                                Expanded(
                                    flex: 3,
                                    child: SalesHeaderText('CUSTOMER NAME')),
                                Expanded(
                                    flex: 2,
                                    child: SalesHeaderText('INVOICE #')),
                                Expanded(
                                    flex: 2,
                                    child: SalesHeaderText('DELIVERY DATE')),
                                Expanded(
                                    flex: 2, child: SalesHeaderText('STATUS')),
                                Expanded(
                                    flex: 2, child: SalesHeaderText('AMOUNT')),
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
                          else if (_loadError != null)
                            Container(
                                width: tableWidth,
                                padding: const EdgeInsets.all(24),
                                child: Text(_loadError!,
                                    style: const TextStyle(color: Colors.red)))
                          else if (_challans.isEmpty)
                            Container(
                              width: tableWidth,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 24),
                              child: const Text(
                                'No delivery challans found. Click "+ New Challan" to add one!',
                                style: TextStyle(
                                    fontSize: 16, color: Color(0xFF42474D)),
                              ),
                            )
                          else
                            ..._visibleChallans.map((challan) {
                              return Column(
                                children: [
                                  Container(
                                    width: tableWidth,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            DateFormat('dd MMM yyyy')
                                                .format(challan.challanDate),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: Text(challan.challanNumber)),
                                        Expanded(
                                            flex: 3,
                                            child: Text(challan.customerName)),
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                challan.invoiceNumber ?? '-')),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            challan.deliveryDate == null
                                                ? '-'
                                                : DateFormat('dd MMM yyyy')
                                                    .format(
                                                        challan.deliveryDate!),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: challan.status == 'Void'
                                              ? const Text(
                                                  'Void',
                                                  style: TextStyle(
                                                    color: Color(0xFFAB2A2A),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                )
                                              : DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    isExpanded: true,
                                                    dropdownColor: Colors.white,
                                                    value: const [
                                                      'Draft',
                                                      'Shipped',
                                                      'Delivered'
                                                    ].contains(challan.status)
                                                        ? challan.status
                                                        : 'Draft',
                                                    items: const [
                                                      DropdownMenuItem(
                                                          value: 'Draft',
                                                          child: Text('Draft')),
                                                      DropdownMenuItem(
                                                          value: 'Shipped',
                                                          child:
                                                              Text('Shipped')),
                                                      DropdownMenuItem(
                                                          value: 'Delivered',
                                                          child: Text(
                                                              'Delivered')),
                                                    ],
                                                    onChanged: (status) {
                                                      if (status != null &&
                                                          status !=
                                                              challan.status) {
                                                        _updateStatus(
                                                            challan, status);
                                                      }
                                                    },
                                                  ),
                                                ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: Text(
                                                'INR ${challan.total.toStringAsFixed(2)}')),
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                tooltip: 'View',
                                                onPressed: () =>
                                                    _viewChallan(challan),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints
                                                        .tightFor(
                                                  width: 28,
                                                  height: 28,
                                                ),
                                                icon: const Icon(
                                                    Icons.visibility,
                                                    size: 18,
                                                    color: Color(0xFF777777)),
                                              ),
                                              IconButton(
                                                tooltip: 'Edit',
                                                onPressed: () =>
                                                    _editChallan(challan),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints
                                                        .tightFor(
                                                  width: 28,
                                                  height: 28,
                                                ),
                                                icon: const Icon(Icons.edit,
                                                    size: 18,
                                                    color: Color(0xFF777777)),
                                              ),
                                              IconButton(
                                                tooltip: 'Clone',
                                                onPressed: () =>
                                                    _cloneChallan(challan),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints
                                                        .tightFor(
                                                  width: 28,
                                                  height: 28,
                                                ),
                                                icon: const Icon(
                                                    Icons.content_copy,
                                                    size: 18,
                                                    color: Color(0xFF777777)),
                                              ),
                                              IconButton(
                                                tooltip: 'Delete',
                                                onPressed: () =>
                                                    _confirmDeleteChallan(
                                                        challan),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints
                                                        .tightFor(
                                                  width: 28,
                                                  height: 28,
                                                ),
                                                icon: const Icon(Icons.delete,
                                                    size: 18,
                                                    color: Color(0xFF777777)),
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
                          _paginationControls(),
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
