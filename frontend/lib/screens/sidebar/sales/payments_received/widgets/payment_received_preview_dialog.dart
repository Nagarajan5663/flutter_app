import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../payment_received_model.dart';

class PaymentReceivedPreviewDialog extends StatelessWidget {
  const PaymentReceivedPreviewDialog({
    required this.payment,
    required this.onDownloadPdf,
    required this.onSendMail,
    super.key,
  });

  final PaymentReceivedModel payment;
  final Future<void> Function() onDownloadPdf;
  final Future<void> Function() onSendMail;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final date = DateFormat('dd MMM yyyy').format(payment.paymentDate);
    final amount = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'INR',
      decimalDigits: 2,
    ).format(payment.amountReceived);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: screen.width < 1000 ? screen.width - 40 : 900,
        height: screen.height < 700 ? screen.height - 40 : screen.height * .9,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 12, 22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.customerName,
                          style: const TextStyle(
                            color: Color(0xFF123456),
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${payment.paymentNumber} | $date',
                          style: const TextStyle(
                            color: Color(0xFF4E555B),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onDownloadPdf,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD0D0D0),
                      foregroundColor: const Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: onSendMail,
                    icon: const Icon(Icons.mail_outline),
                    label: const Text('Send Mail'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD0D0D0),
                      foregroundColor: const Color(0xFF333333),
                    ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(34, 48, 34, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount Received',
                      style: TextStyle(fontSize: 17, color: Color(0xFF444444)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      amount,
                      style: const TextStyle(
                        color: Color(0xFF123456),
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    _detailLine('Paid To:', payment.customerName),
                    _detailLine('Invoice Paid:', '#${payment.invoiceNumber}'),
                    _detailLine('Payment Mode:', payment.paymentMode),
                    _detailLine(
                      'UTR / Reference #:',
                      payment.utrReference.isEmpty
                          ? 'N/A'
                          : payment.utrReference,
                    ),
                    _detailLine(
                      'Remarks:',
                      payment.remarks.isEmpty ? 'N/A' : payment.remarks,
                      isLast: true,
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

  Widget _detailLine(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFD9DEE5),
                  style: BorderStyle.solid,
                ),
              ),
            ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF606060), fontSize: 16),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF444444), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
