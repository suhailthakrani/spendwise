import 'package:flutter_test/flutter_test.dart';

import 'package:spendwise/app/app.dart';

void main() {
  testWidgets('SpendWise app loads dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const SpendWiseApp());
    await tester.pumpAndSettle();

    expect(find.text('SpendWise'), findsOneWidget);
    expect(find.text('Spent This Month'), findsOneWidget);
  });
}
