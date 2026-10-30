import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/sidebar/sales/estimates/estimates_page.dart';
import 'package:intl/intl.dart';

void main() {
  test('Estimate payload preserves selected date values', () {
    final estimate = EstimateData(
      date: DateTime(2026, 10, 22),
      estimateNumber: 'EST-42',
      customerId: 1,
      customerName: 'Test Customer',
      salesPerson: '',
      expiryDate: DateTime(2026, 11, 22),
      items: const [],
      subTotal: 0,
      total: 0,
    );

    final payload = estimate.toCreateJson();
    expect(payload['date'], '2026-10-22');
    expect(payload['expiryDate'], '2026-11-22');
  });

  testWidgets('Item options are searchable and readable in both themes',
      (tester) async {
    const monitor = CatalogOption(
      sourceType: 'Item',
      id: 1,
      name: 'Monitor',
      sku: 'MON-100',
      description: 'HD monitor',
      rate: 125.50,
    );
    const cpu = CatalogOption(
      sourceType: 'Item',
      id: 2,
      name: 'cpu',
      sku: 'CPU-200',
      description: 'Processor',
      rate: 89.00,
    );
    const catalog = [monitor, cpu];

    final searchResults = searchCatalogOptions(catalog, ' mon-100 ');
    expect(searchResults, [monitor]);
    expect(searchCatalogOptions(catalog, 'cp'), [cpu]);
    expect(searchCatalogOptions(catalog, 'mon'), [monitor]);
    expect(searchCatalogOptions(catalog, 'CPU'), [cpu]);
    expect(searchCatalogOptions(catalog, ' cpu-200 '), [cpu]);
    expect(searchCatalogOptions(catalog, 'Item'), isEmpty);
    expect(searchCatalogOptions(catalog, ''), catalog);

    for (final brightness in [Brightness.light, Brightness.dark]) {
      CatalogOption? selectedItem;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: brightness,
          ),
          home: Scaffold(
            body: CatalogOptionsView(
              items: searchResults,
              onSelected: (value) => selectedItem = value,
            ),
          ),
        ),
      );

      final dropdownBackground = tester.widget<Material>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Material &&
              widget.color == Colors.white &&
              widget.surfaceTintColor == Colors.transparent,
        ),
      );
      expect(dropdownBackground.color, Colors.white);
      expect(find.text('Monitor'), findsOneWidget);
      expect(find.text('MON-100 • INR 125.50'), findsOneWidget);
      expect(find.text('cpu'), findsNothing);

      final optionTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(optionTile.tileColor, Colors.white);
      expect(optionTile.hoverColor, const Color(0xFFF1F5F9));
      expect(
        tester.widget<Text>(find.text('Monitor')).style?.color,
        const Color(0xFF263746),
      );
      expect(
        tester.widget<Text>(find.text('MON-100 • INR 125.50')).style?.color,
        const Color(0xFF64748B),
      );
      expect(
        tester.widget<Text>(find.text('Item')).style?.color,
        const Color(0xFF1565C0),
      );
      final badge = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Item'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (badge.decoration! as BoxDecoration).color,
        const Color(0xFFE3F2FD),
      );

      await tester.tap(find.text('Monitor'));
      expect(selectedItem, same(monitor));
      expect(selectedItem!.rate, 125.50);
      expect(selectedItem!.description, 'HD monitor');
      expect(
        EstimateItem(
          sourceType: selectedItem!.sourceType,
          itemId: selectedItem!.id,
          itemName: selectedItem!.name,
          description: selectedItem!.description,
          qty: 2,
          rate: selectedItem!.rate,
        ).amount,
        251,
      );
    }
  });

  testWidgets('Item dropdown displays an empty search message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CatalogOptionsView(
            items: const [],
            onSelected: (_) {},
            showNoResults: true,
          ),
        ),
      ),
    );

    expect(find.text('No items found'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('Customer options stay readable in light and dark themes',
      (tester) async {
    const customer = CustomerOption(
      id: 1,
      name: 'Alex Customer',
      companyName: 'North Star Company',
      email: 'alex@example.com',
      phone: '555-0100',
    );

    for (final brightness in [Brightness.light, Brightness.dark]) {
      CustomerOption? selectedCustomer;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: brightness,
          ),
          home: Scaffold(
            body: CustomerOptionsView(
              customers: const [customer],
              onSelected: (value) => selectedCustomer = value,
            ),
          ),
        ),
      );

      final dropdownBackground = tester.widget<Material>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Material &&
              widget.color == Colors.white &&
              widget.surfaceTintColor == Colors.transparent,
        ),
      );
      expect(dropdownBackground.color, Colors.white);

      final optionTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(optionTile.tileColor, Colors.white);
      expect(optionTile.hoverColor, const Color(0xFFDCEEFF));
      expect(
        tester.widget<Text>(find.text('Alex Customer')).style?.color,
        const Color(0xFF172B4D),
      );
      expect(
        tester.widget<Text>(find.text('North Star Company')).style?.color,
        const Color(0xFF425466),
      );

      await tester.tap(find.text('Alex Customer'));
      expect(selectedCustomer, same(customer));
    }
  });

  testWidgets('New Estimate fields, rows, totals, dates, and cancel work',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const NewEstimateDialog(nextNumber: 'EST-42'),
              ),
              child: const Text('Open form'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    final customerField = textFields.at(0);
    final customerInput = tester.widget<TextField>(
      find.descendant(
        of: customerField,
        matching: find.byType(TextField),
      ),
    );
    expect(customerInput.style?.color, Colors.black);
    expect(customerInput.decoration?.fillColor, Colors.white);
    expect(
      customerInput.decoration?.hintStyle?.color,
      const Color(0xFF757575),
    );
    final itemInput = tester.widget<TextField>(
      find.descendant(
        of: textFields.at(3),
        matching: find.byType(TextField),
      ),
    );
    expect(itemInput.style?.color, const Color(0xFF263746));
    expect(itemInput.decoration?.fillColor, Colors.white);
    expect(
      itemInput.decoration?.hintStyle?.color,
      const Color(0xFF64748B),
    );
    expect(itemInput.cursorColor, const Color(0xFF1E78B7));
    await tester.enterText(customerField, 'Typed customer');
    expect(find.text('Typed customer'), findsOneWidget);

    final estimateNumberTextField = tester.widget<TextField>(
      find.descendant(
        of: textFields.at(1),
        matching: find.byType(TextField),
      ),
    );
    expect(estimateNumberTextField.readOnly, isTrue);
    expect(find.text('EST-42'), findsOneWidget);
    await tester.enterText(textFields.at(2), 'Typed sales person');
    await tester.enterText(textFields.at(3), 'Typed item');
    await tester.enterText(textFields.at(4), 'Typed description');
    await tester.enterText(textFields.at(5), '3');
    await tester.enterText(textFields.at(6), '12.50');
    await tester.pump();

    expect(find.text('Typed sales person'), findsOneWidget);
    expect(find.text('Typed item'), findsOneWidget);
    expect(find.text('Typed description'), findsOneWidget);
    expect(find.text('INR 37.50'), findsNWidgets(3));

    await tester.ensureVisible(find.text('Add Row'));
    await tester.tap(find.text('Add Row'));
    await tester.pumpAndSettle();
    final expandedTextFields = find.byType(TextFormField);
    await tester.ensureVisible(expandedTextFields.at(7));
    await tester.enterText(expandedTextFields.at(7), 'Second item');
    await tester.enterText(expandedTextFields.at(8), 'Second description');
    await tester.enterText(expandedTextFields.at(9), '2');
    await tester.enterText(expandedTextFields.at(10), '3');
    await tester.pump();
    expect(find.text('INR 6.00'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNWidgets(3));
    await tester.tap(find.byIcon(Icons.close).at(2));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.close), findsNWidgets(2));
    expect(find.text('Typed item'), findsOneWidget);
    expect(find.text('Second item'), findsNothing);
    expect(find.text('INR 37.50'), findsNWidgets(3));

    final calendarIcons = tester.widgetList<Icon>(
      find.byIcon(Icons.calendar_today_outlined),
    );
    expect(calendarIcons, hasLength(2));
    for (final icon in calendarIcons) {
      expect(icon.color, const Color(0xFF1F2937));
      expect(icon.size, 16);
    }

    final newCalendar = find.byKey(
      const ValueKey('estimate-new-calendar'),
    );
    await tester
        .ensureVisible(find.byIcon(Icons.calendar_today_outlined).first);
    await tester.tap(find.byIcon(Icons.calendar_today_outlined).first);
    await tester.pumpAndSettle();
    expect(newCalendar, findsOneWidget);
    final calendarRect = tester.getRect(newCalendar);
    expect(calendarRect.left, greaterThanOrEqualTo(0));
    expect(calendarRect.right, lessThanOrEqualTo(1400));
    expect(calendarRect.top, greaterThanOrEqualTo(0));
    expect(calendarRect.bottom, lessThanOrEqualTo(1000));
    final dateField = find
        .ancestor(
          of: find.byIcon(Icons.calendar_today_outlined).first,
          matching: find.byType(InkWell),
        )
        .first;
    expect(
      calendarRect.top,
      closeTo(tester.getRect(dateField).bottom + 6, 1),
    );

    final previousMonth =
        DateTime(DateTime.now().year, DateTime.now().month - 1);
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    final selectedDate = DateTime(previousMonth.year, previousMonth.month, 15);
    await tester.tap(
      find.byKey(
        ValueKey(
          'estimate-new-calendar-day-${DateFormat('yyyy-MM-dd').format(selectedDate)}',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(newCalendar, findsNothing);
    expect(find.text(DateFormat('dd-MM-yyyy').format(selectedDate)),
        findsOneWidget);

    await tester.tap(find.text(DateFormat('dd-MM-yyyy').format(selectedDate)));
    await tester.pumpAndSettle();
    expect(newCalendar, findsOneWidget);
    await tester.tap(
      find.descendant(of: newCalendar, matching: find.text('Clear')),
    );
    await tester.pumpAndSettle();
    expect(newCalendar, findsNothing);
    final today = DateTime.now();
    expect(find.text(DateFormat('dd-MM-yyyy').format(today)), findsOneWidget);

    await tester.ensureVisible(find.byIcon(Icons.calendar_today_outlined).last);
    await tester.tap(find.byIcon(Icons.calendar_today_outlined).last);
    await tester.pumpAndSettle();
    expect(newCalendar, findsOneWidget);
    await tester.tap(
      find.descendant(of: newCalendar, matching: find.text('Clear')),
    );
    await tester.pumpAndSettle();
    expect(find.text('dd-mm-yyyy'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_today_outlined).last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: newCalendar, matching: find.text('Today')),
    );
    await tester.pumpAndSettle();
    expect(find.text(DateFormat('dd-MM-yyyy').format(today)), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.calendar_today_outlined).last);
    await tester.pumpAndSettle();
    expect(newCalendar, findsOneWidget);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(newCalendar, findsNothing);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('New Estimate'), findsNothing);

    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect(find.text('New Estimate'), findsNothing);
  });
}
