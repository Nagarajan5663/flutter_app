import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/sidebar/purchase/payments_made/payment_made_model.dart';

void main() {
  test('payment made data maps the payment details used by the preview', () {
    final payment = PaymentMadeModel.fromJson({
      'id': 92,
      'paymentNumber': 'PAY-92',
      'billId': 1,
      'billNumber': 'BILL-1',
      'vendorName': 'Vikky',
      'vendorInvoiceNumber': 'INV-1',
      'date': '2026-10-09',
      'amount': 49000,
      'mode': 'Bank Transfer',
      'reference': 'TXN-92',
      'paidBy': 'Test user',
      'notes': 'Invoice settled',
      'vendorEmail': 'vendor@example.com',
      'vendorPhone': '+91 98765 43210',
    });

    expect(payment.paymentNumber, 'PAY-92');
    expect(payment.billNumber, 'BILL-1');
    expect(payment.vendorName, 'Vikky');
    expect(payment.amount, 49000);
    expect(payment.paidBy, 'Test user');
    expect(payment.notes, 'Invoice settled');
    expect(payment.vendorEmail, 'vendor@example.com');
    expect(payment.vendorPhone, '+91 98765 43210');
    expect(payment.toJson()['reference'], 'TXN-92');
  });
}
