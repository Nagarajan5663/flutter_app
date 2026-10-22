import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/sidebar/sales/sales_orders/sales_orders_page.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('New Sales Order date fields open independent calendars',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var orderDate = DateTime.now();
    DateTime? shipmentDate;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SalesOrderDatePickerField(
                    key: const ValueKey('order-date'),
                    value: orderDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    canClear: false,
                    calendarKey: const ValueKey('sales-order-form-calendar'),
                    decoration: const InputDecoration(),
                    onChanged: (date) {
                      if (date != null) setState(() => orderDate = date);
                    },
                  ),
                  const SizedBox(height: 20),
                  SalesOrderDatePickerField(
                    key: const ValueKey('shipment-date'),
                    value: shipmentDate,
                    firstDate: orderDate,
                    lastDate: DateTime(2100),
                    calendarKey: const ValueKey('sales-order-form-calendar'),
                    decoration: const InputDecoration(),
                    onChanged: (date) => setState(() => shipmentDate = date),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final icons = find.byIcon(Icons.calendar_today_outlined);
    expect(icons, findsNWidgets(2));
    for (final icon in tester.widgetList<Icon>(icons)) {
      expect(icon.color, const Color(0xFF1F2937));
      expect(icon.size, 16);
    }

    final popup = find.byKey(const ValueKey('sales-order-form-calendar'));
    await tester.tap(icons.first);
    await tester.pumpAndSettle();
    expect(popup, findsOneWidget);
    expect(
      tester.getTopLeft(popup).dy,
      closeTo(
          tester.getRect(find.byKey(const ValueKey('order-date'))).bottom + 6,
          1),
    );
    final clearButton = tester.widget<TextButton>(
      find
          .ancestor(
            of: find.descendant(of: popup, matching: find.text('Clear')),
            matching: find.byType(TextButton),
          )
          .first,
    );
    expect(clearButton.onPressed, isNull);

    final now = DateTime.now();
    final chosenDate = DateTime(
      now.year,
      now.month,
      now.day > 1 ? now.day - 1 : now.day,
    );
    await tester.tap(
      find.byKey(
        ValueKey(
          'sales-order-calendar-day-${DateFormat('yyyy-MM-dd').format(chosenDate)}',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(popup, findsNothing);
    expect(orderDate, chosenDate);
    expect(
        find.text(DateFormat('dd-MM-yyyy').format(chosenDate)), findsOneWidget);

    await tester.tap(icons.last);
    await tester.pumpAndSettle();
    expect(popup, findsOneWidget);
    expect(
      tester.getTopLeft(popup).dy,
      closeTo(
        tester.getRect(find.byKey(const ValueKey('shipment-date'))).bottom + 6,
        1,
      ),
    );
    await tester.tap(
      find.descendant(of: popup, matching: find.text('Today')),
    );
    await tester.pumpAndSettle();
    expect(
        shipmentDate,
        DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day));

    await tester.tap(find.byKey(const ValueKey('shipment-date')));
    await tester.pumpAndSettle();
    expect(popup, findsOneWidget);
    await tester.tap(
      find.descendant(of: popup, matching: find.text('Clear')),
    );
    await tester.pumpAndSettle();
    expect(shipmentDate, isNull);
    expect(find.text('dd-mm-yyyy'), findsOneWidget);

    await tester.tap(icons.first);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(popup, findsNothing);
  });
}
