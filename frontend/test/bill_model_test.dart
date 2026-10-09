import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/sidebar/purchase/bills/bill_model.dart';

void main() {
  test('void state is retained and overrides the payment status', () {
    final bill = BillModel.fromJson({
      'id': '42',
      'billNumber': 'BILL-42',
      'vendorId': '3',
      'vendorName': 'Example vendor',
      'billDate': '2026-10-09',
      'items': const [],
      'amountPaid': 20,
      'isVoided': 1,
    });

    expect(bill.isVoided, isTrue);
    expect(bill.status, 'Void');
    expect(bill.copyWith(amountPaid: 50).isVoided, isTrue);
    expect(bill.toJson()['isVoided'], isTrue);
  });
}
