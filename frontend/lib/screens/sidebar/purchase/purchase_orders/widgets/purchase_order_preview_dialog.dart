import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';

import '../../../../../utils/pdf_file_download.dart';
import '../purchase_order_model.dart';
import '../../vendors/vendor_model.dart';

class PurchaseOrderPreviewDialog extends StatefulWidget {
  const PurchaseOrderPreviewDialog({
    super.key,
    required this.order,
    this.vendor,
    required this.onConvertToBill,
    required this.onVoid,
  });

  final PurchaseOrderModel order;
  final VendorModel? vendor;
  final Future<bool> Function() onConvertToBill;
  final Future<bool> Function() onVoid;

  @override
  State<PurchaseOrderPreviewDialog> createState() =>
      _PurchaseOrderPreviewDialogState();
}

class _PurchaseOrderPreviewDialogState
    extends State<PurchaseOrderPreviewDialog> {
  bool _isBusy = false;

  PurchaseOrderModel get order => widget.order;

  String get _formattedDate => DateFormat('d | dd/MM/yyyy').format(order.date);

  Future<void> _downloadPdf() async {
    setState(() => _isBusy = true);
    try {
      final filename =
          'purchase-order-${order.poNumber.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '-')}.pdf';
      final downloaded = await downloadPdfFile(
        await _buildPdf().save(),
        filename,
      );
      if (mounted && downloaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase order PDF downloaded')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to create purchase order PDF: $error')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String get _shareText {
    final currency = NumberFormat('#,##0.00', 'en_IN');
    final reference = order.referenceNumber.isEmpty
        ? ''
        : '\nReference: ${order.referenceNumber}';
    final items = order.items
        .map(
          (item) => '- ${item.itemName} x ${item.qty.toStringAsFixed(2)}: '
              'INR ${currency.format(item.amount)}',
        )
        .join('\n');
    return 'Purchase Order ${order.poNumber}\n'
        'Vendor: ${order.vendorName}\n'
        'Date: ${DateFormat('dd/MM/yyyy').format(order.date)}'
        '$reference\n'
        'Items:\n${items.isEmpty ? '- None' : items}\n'
        'Total: INR ${currency.format(order.total)}';
  }

  Future<void> _send(String channel) async {
    setState(() => _isBusy = true);
    try {
      final subject = 'Purchase Order ${order.poNumber}';
      final recipient = channel == 'whatsapp'
          ? widget.vendor?.phone.trim() ?? ''
          : widget.vendor?.email.trim() ?? '';
      final phone = recipient.replaceAll(RegExp(r'[^0-9]'), '');
      if (channel == 'whatsapp' && phone.length < 7) {
        throw Exception(
          'Add a valid vendor phone number in the vendor record before sending.',
        );
      }
      if (channel == 'mail' &&
          (recipient.isEmpty || !recipient.contains('@'))) {
        throw Exception(
          'Add a valid vendor email in the vendor record before sending.',
        );
      }
      final Uri uri = channel == 'whatsapp'
          ? Uri.https(
              'wa.me',
              '/$phone',
              {'text': _shareText},
            )
          : Uri(
              scheme: 'mailto',
              path: recipient,
              queryParameters: {
                'subject': subject,
                'body': _shareText,
              },
            );
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('No app is available to open the selected recipient');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open $channel: $error')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _convertToBill() async {
    setState(() => _isBusy = true);
    try {
      if (await widget.onConvertToBill() && mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _voidOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Void purchase order?'),
        content: Text(
          'Mark purchase order ${order.poNumber} as Cancelled?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
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
      if (await widget.onVoid() && mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  pw.Document _buildPdf() {
    final document = pw.Document();
    final currency = NumberFormat('#,##0.00', 'en_IN');

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            order.vendorName,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#123456'),
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(DateFormat('d | dd/MM/yyyy').format(order.date)),
          if (order.referenceNumber.isNotEmpty)
            pw.Text('Reference: ${order.referenceNumber}'),
          pw.SizedBox(height: 24),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Item & Description',
              'Qty',
              'Rate',
              'Amount',
            ],
            data: order.items
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
            headerDecoration:
                pw.BoxDecoration(color: PdfColor.fromHex('#F5F6F7')),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#333333'),
            ),
            cellPadding: const pw.EdgeInsets.all(8),
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(
                color: PdfColor.fromHex('#D9DEE5'),
                width: 0.6,
              ),
              bottom: pw.BorderSide(
                color: PdfColor.fromHex('#D9DEE5'),
                width: 0.6,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Sub Total: INR ${currency.format(order.subTotal)}'),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Total: INR ${currency.format(order.total)}',
                  style: pw.TextStyle(
                    fontSize: 17,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return document;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final currency = NumberFormat('#,##0.00', 'en_IN');
    final isNarrow = screenSize.width < 1000;
    final orderInfo = Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.vendorName,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFF123456),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formattedDate,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B6B6B),
            ),
          ),
          if (order.referenceNumber.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Reference: ${order.referenceNumber}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B6B6B),
                ),
              ),
            ),
        ],
      ),
    );
    final actions = Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: _isBusy ? null : _downloadPdf,
          icon: const Icon(Icons.download_outlined, size: 18),
          label: const Text('Download PDF'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFCCCCCC),
            foregroundColor: const Color(0xFF252A31),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Send purchase order',
          enabled: !_isBusy,
          onSelected: _send,
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'email',
              child: Text('Send Mail'),
            ),
            PopupMenuItem(
              value: 'whatsapp',
              child: Text('Send WhatsApp'),
            ),
          ],
          child: _ActionButton(
            label: 'Send',
            icon: Icons.send_outlined,
            color: const Color(0xFF3498DB),
            trailing: Icons.arrow_drop_down,
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Convert purchase order',
          enabled: !_isBusy,
          onSelected: (_) => _convertToBill(),
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'bill',
              child: Text('Convert to Bill'),
            ),
          ],
          child: _ActionButton(
            label: 'Convert As',
            color: const Color(0xFF3498DB),
            trailing: Icons.arrow_drop_down,
          ),
        ),
        FilledButton(
          onPressed: _isBusy || order.status == 'Cancelled' ? null : _voidOrder,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF849394),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
          ),
          child: const Text('Void'),
        ),
        IconButton(
          onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
          tooltip: 'Close',
          icon: const Icon(
            Icons.close,
            color: Color(0xFF8A8A8A),
          ),
        ),
      ],
    );

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: SizedBox(
        width: screenSize.width < 1100 ? screenSize.width - 32 : 1000,
        height: isNarrow
            ? screenSize.height - 32
            : screenSize.height < 450
                ? screenSize.height - 32
                : 335,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 18, 14, 18),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE1E4E8)),
                ),
              ),
              child: isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        orderInfo,
                        const SizedBox(height: 12),
                        actions,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: orderInfo),
                        actions,
                      ],
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 7,
                      child: SingleChildScrollView(
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2.5),
                            1: FlexColumnWidth(1.1),
                            2: FlexColumnWidth(1.7),
                            3: FlexColumnWidth(1.7),
                          },
                          border: const TableBorder(
                            horizontalInside: BorderSide(
                              color: Color(0xFFD9DEE5),
                            ),
                            bottom: BorderSide(color: Color(0xFFD9DEE5)),
                          ),
                          children: [
                            TableRow(
                              decoration:
                                  const BoxDecoration(color: Color(0xFFF5F6F7)),
                              children: const [
                                _PreviewCell('Item & Description',
                                    header: true),
                                _PreviewCell('Qty', header: true),
                                _PreviewCell('Rate', header: true),
                                _PreviewCell('Amount', header: true),
                              ],
                            ),
                            ...order.items.map(
                              (item) => TableRow(
                                children: [
                                  _PreviewItemCell(
                                    name: item.itemName,
                                    description: item.description,
                                  ),
                                  _PreviewCell(item.qty.toStringAsFixed(2)),
                                  _PreviewCell(
                                    'INR ${currency.format(item.rate)}',
                                  ),
                                  _PreviewCell(
                                    'INR ${currency.format(item.amount)}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 26),
                    const VerticalDivider(width: 1, color: Color(0xFFD9DEE5)),
                    const SizedBox(width: 26),
                    Expanded(
                      flex: 4,
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
                          _SummaryLine(
                            label: 'Sub Total',
                            value: 'INR ${currency.format(order.subTotal)}',
                          ),
                          const Spacer(),
                          _SummaryLine(
                            label: 'Total',
                            value: 'INR ${currency.format(order.total)}',
                            total: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    this.icon,
    this.trailing,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 7),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailing != null) Icon(trailing, color: Colors.white),
        ],
      ),
    );
  }
}

class _PreviewCell extends StatelessWidget {
  const _PreviewCell(this.text, {this.header = false});

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

class _PreviewItemCell extends StatelessWidget {
  const _PreviewItemCell({
    required this.name,
    required this.description,
  });

  final String name;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (description.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF6B6B6B),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.total = false,
  });

  final String label;
  final String value;
  final bool total;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: total ? 15 : 14,
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
            fontSize: total ? 19 : 14,
            fontWeight: total ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
