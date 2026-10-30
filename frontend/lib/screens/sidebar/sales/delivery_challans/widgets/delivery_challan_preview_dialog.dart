import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../delivery_challan_model.dart';

class DeliveryChallanPreviewDialog extends StatelessWidget {
  const DeliveryChallanPreviewDialog({
    required this.challan,
    required this.onDownloadPdf,
    required this.onSendMail,
    required this.onVoid,
    super.key,
  });

  final DeliveryChallanModel challan;
  final Future<void> Function() onDownloadPdf;
  final Future<void> Function() onSendMail;
  final Future<void> Function() onVoid;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final money = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'INR',
      decimalDigits: 2,
    );
    final date = DateFormat('M/d/yyyy').format(challan.challanDate);

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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challan.customerName,
                          style: const TextStyle(
                            color: Color(0xFF123456),
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${challan.challanNumber} | $date',
                          style: const TextStyle(
                            color: Color(0xFF4E555B),
                            fontSize: 16,
                          ),
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
                      ElevatedButton.icon(
                        onPressed: onSendMail,
                        icon: const Icon(Icons.mail_outline),
                        label: const Text('Send Mail'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD0D0D0),
                          foregroundColor: const Color(0xFF333333),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: challan.status == 'Void'
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
                            for (final item in challan.items)
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
                              'Sub Total', money.format(challan.total)),
                          _summaryLine(
                            'Total',
                            money.format(challan.total),
                            bold: true,
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

  Widget _summaryLine(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      color: const Color(0xFF444444),
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
