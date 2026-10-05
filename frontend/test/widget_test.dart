import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/screens/dashboard/widgets/read_only_preview_scope.dart';
import 'package:flutter_app/screens/sidebar/settings/preferences_page.dart';

void main() {
  testWidgets('Codexia app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CodexiaApp());

    expect(find.byType(CodexiaApp), findsOneWidget);
  });

  testWidgets('read-only pages keep scrolling and back navigation',
      (WidgetTester tester) async {
    var wentBack = false;
    var actionTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ReadOnlyPreviewScope(
          readOnly: true,
          child: Builder(
            builder: (context) => Scaffold(
              body: ReadOnlyPreviewScope.blockScrollableActions(
                context,
                Column(
                  children: [
                    ReadOnlyPreviewScope.allowNavigation(
                      TextButton(
                        onPressed: () => wentBack = true,
                        child: const Text('Back to settings'),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: [
                          TextButton(
                            onPressed: () => actionTriggered = true,
                            child: const Text('Read-only action'),
                          ),
                          ...List.generate(
                            30,
                            (index) => SizedBox(
                                height: 60, child: Text('Entry $index')),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final initialOffset = tester.getTopLeft(find.text('Entry 29')).dy;
    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(
        tester.getTopLeft(find.text('Entry 29')).dy, lessThan(initialOffset));

    await tester.tap(find.text('Back to settings'));
    expect(wentBack, isTrue);

    await tester.tap(find.text('Read-only action'));
    expect(actionTriggered, isFalse);
  });

  testWidgets('read-only preferences can return to the dashboard',
      (WidgetTester tester) async {
    var wentBack = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ReadOnlyPreviewScope(
          readOnly: true,
          child: Scaffold(
            body: PreferencesPage(onBack: () => wentBack = true),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Back to dashboard'));
    expect(wentBack, isTrue);
  });
}
