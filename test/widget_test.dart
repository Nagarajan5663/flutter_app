import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('Codexia app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CodexiaApp());

    expect(find.byType(CodexiaApp), findsOneWidget);
  });
}