import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spendwise/app/app.dart';
import 'package:spendwise/core/database/app_database.dart';
import 'package:spendwise/providers/database_provider.dart';

void main() {
  testWidgets('SpendWise app loads dashboard', (WidgetTester tester) async {
    final database = AppDatabase.memory();
    await database.select(database.categories).get();

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SpendWiseApp(),
      ),
    );
    await tester.pumpAndSettle();

    final greeting = find.byWidgetPredicate(
      (widget) {
        if (widget is! Text) return false;
        final text = widget.data;
        return text == 'Good morning' ||
            text == 'Good afternoon' ||
            text == 'Good evening';
      },
    );
    expect(greeting, findsOneWidget);
    expect(find.text('Spent this month'), findsOneWidget);
  });
}
