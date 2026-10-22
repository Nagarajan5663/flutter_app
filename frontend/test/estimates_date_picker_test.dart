import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/sidebar/sales/estimates/estimates_page.dart';
import 'package:intl/intl.dart';

String _calendarDayKey(DateTime date) =>
    'estimate-calendar-day-${DateFormat('yyyy-MM-dd').format(date)}';

void main() {
  testWidgets(
      'Estimate date filters show compact calendar, navigation, clear, and today',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF17395C),
            brightness: Brightness.dark,
          ),
        ),
        home: const Scaffold(body: EstimatesPage()),
      ),
    );
    await tester.pumpAndSettle();

    final calendarIcons = tester.widgetList<Icon>(
      find.byIcon(Icons.calendar_today_outlined),
    );
    expect(calendarIcons, hasLength(2));
    for (final icon in calendarIcons) {
      expect(icon.color, const Color(0xFF1F2937));
      expect(icon.size, 16);
    }

    await tester.tap(find.byIcon(Icons.calendar_today_outlined).first);
    await tester.pumpAndSettle();

    final calendarPopup = find.byKey(
      const ValueKey('estimate-filter-calendar'),
    );
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    expect(find.text(DateFormat('MMMM yyyy').format(currentMonth)),
        findsOneWidget);
    for (final weekday in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) {
      expect(find.text(weekday), findsOneWidget);
    }
    final clearCalendar = find.descendant(
      of: calendarPopup,
      matching: find.text('Clear'),
    );
    final todayCalendar = find.descendant(
      of: calendarPopup,
      matching: find.text('Today'),
    );
    expect(clearCalendar, findsOneWidget);
    expect(todayCalendar, findsOneWidget);

    final desktopPickerRect = tester.getRect(calendarPopup);
    expect(desktopPickerRect.width, lessThanOrEqualTo(340));
    expect(desktopPickerRect.top, greaterThan(0));
    final dateFromField = find
        .ancestor(
          of: find.byIcon(Icons.calendar_today_outlined).first,
          matching: find.byType(InkWell),
        )
        .first;
    expect(
      desktopPickerRect.top,
      closeTo(tester.getRect(dateFromField).bottom + 6, 1),
    );

    final previousMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text(DateFormat('MMMM yyyy').format(previousMonth)),
        findsOneWidget);

    final selectedDate = DateTime(previousMonth.year, previousMonth.month, 15);
    await tester.tap(find.byKey(ValueKey(_calendarDayKey(selectedDate))));
    await tester.pumpAndSettle();
    final selectedDateText = DateFormat('dd-MM-yyyy').format(selectedDate);
    expect(find.text(selectedDateText), findsOneWidget);

    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    expect(find.text(selectedDateText), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_today_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text(DateFormat('MMMM yyyy').format(previousMonth)),
        findsOneWidget);
    final selectedDateCell =
        find.byKey(ValueKey(_calendarDayKey(selectedDate)));
    final selectedCellBackground = tester.widget<Container>(
      find.descendant(
        of: selectedDateCell,
        matching: find.byType(Container),
      ),
    );
    expect(
      (selectedCellBackground.decoration! as BoxDecoration).color,
      const Color(0xFF1E78B7),
    );
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: selectedDateCell,
              matching: find.byType(Text),
            ),
          )
          .style
          ?.color,
      Colors.white,
    );
    final adjacentMonthDate = DateTime(
      previousMonth.year,
      previousMonth.month,
      1,
    ).subtract(const Duration(days: 1));
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(ValueKey(_calendarDayKey(adjacentMonthDate))),
              matching: find.byType(Text),
            ),
          )
          .style
          ?.color,
      const Color(0xFF94A3B8),
    );
    await tester.tap(clearCalendar);
    await tester.pumpAndSettle();
    expect(find.text('dd-mm-yyyy').first, findsOneWidget);
    expect(find.text(selectedDateText), findsNothing);

    await tester.tap(find.byIcon(Icons.calendar_today_outlined).first);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: calendarPopup,
      matching: find.text('Today'),
    ));
    await tester.pumpAndSettle();
    final today = DateTime.now();
    final todayText = DateFormat('dd-MM-yyyy').format(today);
    expect(find.text(todayText), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_today_outlined).last);
    await tester.pumpAndSettle();
    final dateToField = find
        .ancestor(
          of: find.byIcon(Icons.calendar_today_outlined).last,
          matching: find.byType(InkWell),
        )
        .first;
    expect(
      tester.getTopLeft(calendarPopup).dy,
      closeTo(tester.getRect(dateToField).bottom + 6, 1),
    );
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    final disabledEarlierDate = tester
        .widget<InkWell>(find.byKey(ValueKey(_calendarDayKey(yesterday))));
    expect(disabledEarlierDate.onTap, isNull);
    await tester.tap(find.descendant(
      of: calendarPopup,
      matching: find.text('Today'),
    ));
    await tester.pumpAndSettle();
    expect(find.text(todayText), findsNWidgets(2));

    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    await tester.tap(find.text(todayText).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey(_calendarDayKey(tomorrow))));
    await tester.pumpAndSettle();
    final tomorrowText = DateFormat('dd-MM-yyyy').format(tomorrow);
    expect(find.text(tomorrowText), findsNWidgets(2));

    tester.view.physicalSize = const Size(768, 900);
    await tester.pumpAndSettle();
    await tester.tap(find.text(tomorrowText).first);
    await tester.pumpAndSettle();
    final tabletPickerRect = tester.getRect(calendarPopup);
    expect(tabletPickerRect.left, greaterThanOrEqualTo(0));
    expect(tabletPickerRect.right, lessThanOrEqualTo(768));
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(calendarPopup, findsNothing);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.calendar_today_outlined).first);
    await tester.pumpAndSettle();
    final mobilePickerRect = tester.getRect(calendarPopup);
    expect(mobilePickerRect.left, greaterThanOrEqualTo(0));
    expect(mobilePickerRect.right, lessThanOrEqualTo(390));
    expect(
      find.descendant(
        of: calendarPopup,
        matching: find.text('Clear'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: calendarPopup,
        matching: find.text('Today'),
      ),
      findsOneWidget,
    );
  });
}
