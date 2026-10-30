import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/sidebar/sales/sales_orders/sales_orders_page.dart';
import 'package:intl/intl.dart';

String _salesOrderCalendarDayKey(DateTime date) =>
    'sales-order-calendar-day-${DateFormat('yyyy-MM-dd').format(date)}';

void main() {
  testWidgets('Sales Orders date icons open anchored calendars',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SalesOrderPage()),
      ),
    );
    await tester.pumpAndSettle();

    final icons = tester.widgetList<Icon>(
      find.byIcon(Icons.calendar_today_outlined),
    );
    expect(icons, hasLength(2));
    for (final icon in icons) {
      expect(icon.color, const Color(0xFF1F2937));
      expect(icon.size, 16);
    }

    final calendarPopup = find.byKey(
      const ValueKey('sales-order-filter-calendar'),
    );
    final dateFromField = find
        .ancestor(
          of: find.byIcon(Icons.calendar_today_outlined).first,
          matching: find.byType(InkWell),
        )
        .first;
    await tester.tap(find.byIcon(Icons.calendar_today_outlined).first);
    await tester.pumpAndSettle();
    expect(calendarPopup, findsOneWidget);
    expect(
      tester.getTopLeft(calendarPopup).dy,
      closeTo(tester.getRect(dateFromField).bottom + 6, 1),
    );
    expect(
      find.descendant(of: calendarPopup, matching: find.text('Clear')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: calendarPopup, matching: find.text('Today')),
      findsOneWidget,
    );

    final nextMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month + 1,
    );
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(
      find.text(DateFormat('MMMM yyyy').format(nextMonth)),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();

    final selectedDate =
        DateTime(DateTime.now().year, DateTime.now().month, 10);
    await tester.tap(
      find.byKey(ValueKey(_salesOrderCalendarDayKey(selectedDate))),
    );
    await tester.pumpAndSettle();
    expect(calendarPopup, findsNothing);
    final selectedDateText = DateFormat('dd-MM-yyyy').format(selectedDate);
    expect(find.text(selectedDateText), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_today_outlined).last);
    await tester.pumpAndSettle();
    final dateToField = find
        .ancestor(
          of: find.byIcon(Icons.calendar_today_outlined).last,
          matching: find.byType(InkWell),
        )
        .first;
    expect(calendarPopup, findsOneWidget);
    expect(
      tester.getTopLeft(calendarPopup).dy,
      closeTo(tester.getRect(dateToField).bottom + 6, 1),
    );
    await tester.tap(
      find.descendant(of: calendarPopup, matching: find.text('Today')),
    );
    await tester.pumpAndSettle();
    final todayText = DateFormat('dd-MM-yyyy').format(DateTime.now());
    expect(find.text(todayText), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_today_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: calendarPopup, matching: find.text('Clear')),
    );
    await tester.pumpAndSettle();
    expect(find.text('dd-mm-yyyy'), findsOneWidget);

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    expect(calendarPopup, findsNothing);

    await tester.tap(find.byIcon(Icons.calendar_today_outlined).first);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(calendarPopup, findsNothing);
  });
}
