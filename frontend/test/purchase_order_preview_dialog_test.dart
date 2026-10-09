import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/sidebar/purchase/purchase_orders/purchase_order_model.dart';
import 'package:flutter_app/screens/sidebar/purchase/purchase_orders/widgets/purchase_order_preview_dialog.dart';

void main() {
  testWidgets('preview provides email and WhatsApp send options',
      (tester) async {
    await tester.pumpWidget(_previewApp());
    await tester.tap(find.text('Open preview'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.text('Send Mail'), findsOneWidget);
    expect(find.text('Send WhatsApp'), findsOneWidget);
  });

  testWidgets('Convert to Bill invokes conversion and closes preview',
      (tester) async {
    var converted = false;
    await tester.pumpWidget(
      _previewApp(
        onConvertToBill: () async {
          converted = true;
          return true;
        },
      ),
    );
    await tester.tap(find.text('Open preview'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Convert As'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Convert to Bill'));
    await tester.pumpAndSettle();

    expect(converted, isTrue);
    expect(find.text('Download PDF'), findsNothing);
  });

  testWidgets('Void confirms and invokes the cancellation action',
      (tester) async {
    var voided = false;
    await tester.pumpWidget(
      _previewApp(
        onVoid: () async {
          voided = true;
          return true;
        },
      ),
    );
    await tester.tap(find.text('Open preview'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Void'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Void'),
      ),
    );
    await tester.pumpAndSettle();

    expect(voided, isTrue);
    expect(find.text('Download PDF'), findsNothing);
  });
}

Widget _previewApp({
  Future<bool> Function()? onConvertToBill,
  Future<bool> Function()? onVoid,
}) {
  final order = PurchaseOrderModel(
    id: '1',
    poNumber: 'PO-1',
    vendorId: '1',
    vendorName: 'Example vendor',
    date: DateTime(2026, 10, 8),
    paymentTerms: 'Due on Receipt',
    items: const [],
  );

  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => PurchaseOrderPreviewDialog(
              order: order,
              onConvertToBill: onConvertToBill ?? () async => false,
              onVoid: onVoid ?? () async => false,
            ),
          ),
          child: const Text('Open preview'),
        ),
      ),
    ),
  );
}
