import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../invoice_model.dart';

class InvoicePreviewDialog extends StatelessWidget {
  const InvoicePreviewDialog({
    required this.invoice,
    required this.onDownloadPdf,
    required this.onSendEmail,
    required this.onConvertToDeliveryChallan,
    required this.onRecordPayment,
    required this.onVoid,
  });

  final InvoiceModel invoice;
  final Future<void> Function() onDownloadPdf;
  final Future<void> Function() onSendEmail;
  final Future<void> Function() onConvertToDeliveryChallan;
  final Future<void> Function() onRecordPayment;
  final Future<void> Function() onVoid;

  String _invoiceShareMessage() {
    final money = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'INR ',
      decimalDigits: 2,
    );
    final buffer = StringBuffer()
      ..writeln('INVOICE')
      ..writeln('Invoice: ${invoice.invoiceNumber}')
      ..writeln('Customer: ${invoice.customerName}')
      ..writeln('Date: ${DateFormat('dd MMM yyyy').format(invoice.date)}');

    if (invoice.dueDate != null) {
      buffer.writeln(
        'Due Date: ${DateFormat('dd MMM yyyy').format(invoice.dueDate!)}',
      );
    }
    if (invoice.soNumber?.isNotEmpty ?? false) {
      buffer.writeln('Sales Order: ${invoice.soNumber}');
    }
    if (invoice.estimateNumber?.isNotEmpty ?? false) {
      buffer.writeln('Estimate: ${invoice.estimateNumber}');
    }
    if (invoice.deliveryChallanNumber?.isNotEmpty ?? false) {
      buffer.writeln('Delivery Challan: ${invoice.deliveryChallanNumber}');
    }
    buffer
      ..writeln('Document Status: ${invoice.documentStatus}')
      ..writeln('Approval: ${invoice.approvalStatus}')
      ..writeln('Payment Status: ${invoice.status}')
      ..writeln('Credit Terms: ${invoice.creditTerms}')
      ..writeln()
      ..writeln('ITEMS');

    if (invoice.items.isEmpty) {
      buffer.writeln('No line items.');
    } else {
      for (var index = 0; index < invoice.items.length; index++) {
        final item = invoice.items[index];
        buffer
          ..writeln('${index + 1}. ${item.itemName}')
          ..writeln(
              '   Description: ${item.description.isEmpty ? '-' : item.description}')
          ..writeln('   Quantity: ${item.quantity.toStringAsFixed(2)}')
          ..writeln('   Rate: ${money.format(item.rate)}')
          ..writeln('   Amount: ${money.format(item.amount)}');
      }
    }

    buffer
      ..writeln()
      ..writeln('Subtotal: ${money.format(invoice.subTotal)}')
      ..writeln('Tax: ${money.format(invoice.tax)}')
      ..writeln('Total: ${money.format(invoice.total)}')
      ..writeln('Amount Paid: ${money.format(invoice.amountPaid)}')
      ..writeln('Amount Due: ${money.format(invoice.amountDue)}');
    if (invoice.notes.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Notes: ${invoice.notes}');
    }
    if (invoice.termsAndConditions.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Terms and Conditions: ${invoice.termsAndConditions}');
    }
    return buffer.toString().trimRight();
  }

  Future<void> _sendWhatsApp(BuildContext context) async {
    final phone = invoice.customerPhone.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('This customer does not have a phone number.')),
      );
      return;
    }
    final message = _invoiceShareMessage();
    final encoded = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse('https://wa.me/$phone?text=$encoded');
    final alternateUrl =
        Uri.parse('https://api.whatsapp.com/send?phone=$phone&text=$encoded');

    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      if (!await launchUrl(alternateUrl,
          mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('WhatsApp could not be opened.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final dateText =
        '${invoice.date.month}/${invoice.date.day}/${invoice.date.year}';
    final money = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'INR ',
      decimalDigits: 2,
    );
    final remaining = invoice.amountDue;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: screen.width < 1240 ? screen.width - 40 : 1120,
        height: screen.height < 700 ? screen.height - 40 : screen.height * .9,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 12, 16),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 12,
                spacing: 16,
                children: [
                  SizedBox(
                    width: 240,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.customerName,
                          style: const TextStyle(
                            color: Color(0xFF123456),
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${invoice.invoiceNumber} | $dateText',
                          style: const TextStyle(
                            color: Color(0xFF4E555B),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Ref: Sales Order ${invoice.soNumber ?? '-'}',
                          style: const TextStyle(color: Color(0xFF6C7278)),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onDownloadPdf,
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Download PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD0D0D0),
                          foregroundColor: const Color(0xFF333333),
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Send invoice',
                        onSelected: (value) async {
                          if (value == 'email') {
                            await onSendEmail();
                          } else if (value == 'whatsapp') {
                            await _sendWhatsApp(context);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'email',
                            child: Row(
                              children: [
                                Icon(Icons.mail_outline, size: 18),
                                SizedBox(width: 8),
                                Text('Mail'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'whatsapp',
                            child: Row(
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 18),
                                SizedBox(width: 8),
                                Text('WhatsApp'),
                              ],
                            ),
                          ),
                        ],
                        child: IgnorePointer(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.send_outlined),
                            label: const Text('Send'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498DB),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (invoice.approvalStatus == 'Approved')
                        PopupMenuButton<String>(
                          tooltip: 'Convert invoice',
                          onSelected: (value) {
                            if (value == 'challan') {
                              onConvertToDeliveryChallan();
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'challan',
                              enabled: invoice.documentStatus != 'Void',
                              child: Text(
                                invoice.deliveryChallanNumber == null
                                    ? 'Delivery Challan'
                                    : 'Open Delivery Challan ${invoice.deliveryChallanNumber}',
                              ),
                            ),
                          ],
                          child: IgnorePointer(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.keyboard_arrow_down),
                              label: const Text('Convert As'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3498DB),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: remaining <= 0 ? null : onRecordPayment,
                        icon: const Icon(Icons.credit_card),
                        label: const Text('Record Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: invoice.documentStatus == 'Void'
                            ? null
                            : () async {
                                Navigator.of(context).pop();
                                await onVoid();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF849394),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Void'),
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Close preview',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF879098)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 7,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              color: const Color(0xFFF7F8FA),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Item & Description',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Qty',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Rate',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Amount',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            for (final item in invoice.items)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color(0xFFD9DEE5),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.itemName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (item.description.isNotEmpty)
                                            Text(item.description),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        item.quantity.toStringAsFixed(2),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        money.format(item.rate),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        money.format(item.amount),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 34),
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Summary',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            _summaryLine(
                                'Sub Total', money.format(invoice.subTotal)),
                            _summaryLine('Tax', money.format(invoice.tax)),
                            _summaryLine(
                              'Total',
                              money.format(invoice.total),
                              bold: true,
                            ),
                            _summaryLine(
                              'Amount Paid',
                              money.format(invoice.amountPaid),
                              color: const Color(0xFF16B85A),
                            ),
                            _summaryLine('Credit Applied', money.format(0)),
                            _summaryLine(
                              'Amount Due',
                              money.format(remaining),
                              bold: true,
                              color: remaining <= 0
                                  ? const Color(0xFF16B85A)
                                  : const Color(0xFFE74C3C),
                            ),
                          ],
                        ),
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

  Widget _summaryLine(
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    final style = TextStyle(
      color: color ?? const Color(0xFF444444),
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      fontSize: bold ? 17 : 15,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, textAlign: TextAlign.right, style: style),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Text(value, textAlign: TextAlign.right, style: style)),
        ],
      ),
    );
  }
}
