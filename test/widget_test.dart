import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/app.dart';

void main() {
  testWidgets('Dashboard page loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Dashboard'), findsOneWidget);
  });
}