import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/sidebar/sales/sales_orders/sales_orders_page.dart';

void main() {
  testWidgets('Sales Order dropdowns retain contrast in light and dark themes',
      (tester) async {
    const customer = CustomerOption(
      id: 1,
      name: 'Keerthana',
      companyName: 'Codexia Systems',
      email: 'keerthana@example.com',
    );
    const product = CatalogOption(
      sourceType: 'Item',
      id: 3,
      name: 'Monitor',
      sku: 'MON-103',
      description: 'Full HD monitor',
      rate: 125.50,
    );

    expect(searchSalesOrderCustomers([customer], 'keer'), [customer]);
    expect(searchSalesOrderCustomers([customer], 'CODEXIA'), [customer]);
    expect(searchSalesOrderCatalog([product], 'mon'), [product]);
    expect(searchSalesOrderCatalog([product], 'MON-103'), [product]);
    expect(searchSalesOrderCustomers([customer], 'missing'), isEmpty);
    expect(searchSalesOrderCatalog([product], 'missing'), isEmpty);

    for (final brightness in [Brightness.light, Brightness.dark]) {
      CustomerOption? selectedCustomer;
      CatalogOption? selectedProduct;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode:
              brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
          home: Theme(
            data: brightness == Brightness.dark
                ? ThemeData.dark()
                : ThemeData.light(),
            child: Scaffold(
              body: Column(
                children: [
                  SalesOrderCustomerOptionsView(
                    customers: const [customer],
                    onSelected: (value) => selectedCustomer = value,
                  ),
                  SalesOrderCatalogOptionsView(
                    products: const [product],
                    onSelected: (value) => selectedProduct = value,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(
        Theme.of(tester.element(find.byType(SalesOrderCustomerOptionsView)))
            .brightness,
        brightness,
      );

      final isDark = brightness == Brightness.dark;
      final expectedBackground =
          isDark ? const Color(0xFF263746) : Colors.white;
      final expectedPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
      final expectedSecondary =
          isDark ? const Color(0xFFD1D5DB) : const Color(0xFF64748B);
      final dropdownSurfaces = tester.widgetList<Material>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Material &&
              widget.surfaceTintColor == Colors.transparent &&
              widget.elevation == 10,
        ),
      );
      expect(dropdownSurfaces, hasLength(2));
      for (final surface in dropdownSurfaces) {
        expect(surface.color, expectedBackground);
      }

      expect(
        tester.widget<Text>(find.text('Keerthana')).style?.color,
        expectedPrimary,
      );
      expect(
        tester.widget<Text>(find.text('Codexia Systems')).style?.color,
        expectedSecondary,
      );
      expect(
        tester.widget<Text>(find.text('Monitor')).style?.color,
        expectedPrimary,
      );
      expect(
        tester
            .widget<Text>(find.text('MON-103 • Full HD monitor • INR 125.50'))
            .style
            ?.color,
        expectedSecondary,
      );

      await tester.tap(find.text('Keerthana'));
      expect(selectedCustomer, same(customer));
      await tester.tap(find.text('Monitor'));
      expect(selectedProduct, same(product));
      expect(
        SalesOrderItem(
          sourceType: selectedProduct!.sourceType,
          itemId: selectedProduct!.id,
          itemName: selectedProduct!.name,
          description: selectedProduct!.description,
          qty: 2,
          rate: selectedProduct!.rate,
        ).amount,
        251,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode:
              brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
          home: Theme(
            data: brightness == Brightness.dark
                ? ThemeData.dark()
                : ThemeData.light(),
            child: Scaffold(
              body: Column(
                children: [
                  SalesOrderCustomerOptionsView(
                    customers: const [],
                    showNoResults: true,
                    onSelected: (_) {},
                  ),
                  SalesOrderCatalogOptionsView(
                    products: const [],
                    showNoResults: true,
                    onSelected: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.text('No results found'), findsNWidgets(2));
      expect(
        tester.widget<Text>(find.text('No results found').first).style?.color,
        expectedSecondary,
      );
    }
  });

  testWidgets('New Sales Order form text stays readable over dark app themes',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final brightness in [Brightness.light, Brightness.dark]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode:
              brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
          home: Scaffold(
            body: SalesOrderFormTheme(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Customer Name *'),
                    const TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF8FAFB),
                        hintText: 'Select or type to search...',
                        hintStyle: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                    const Text('Item Details'),
                    const TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF8FAFB),
                        hintText: 'Select or type to search...',
                        hintStyle: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      for (final field in find.byType(TextField).evaluate()) {
        final textField = field.widget as TextField;
        final editableText = tester.widget<EditableText>(
          find.descendant(
            of: find.byWidget(textField),
            matching: find.byType(EditableText),
          ),
        );
        expect(editableText.style.color, const Color(0xFF1F2937));
        expect(editableText.cursorColor, const Color(0xFF1E78B7));
        expect(textField.decoration?.fillColor, const Color(0xFFF8FAFB));
        expect(
          textField.decoration?.hintStyle?.color,
          const Color(0xFF64748B),
        );
      }
      expect(
        Theme.of(tester.element(find.byType(TextField).first))
            .textTheme
            .bodyMedium
            ?.color,
        const Color(0xFF1F2937),
      );
    }
  });
}
