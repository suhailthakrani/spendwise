import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spendwise/app/app.dart';
import 'package:spendwise/core/database/app_database.dart';
import 'package:spendwise/core/database/database_seed.dart';
import 'package:spendwise/data/models/user_preferences.dart';
import 'package:spendwise/providers/database_provider.dart';
import 'package:spendwise/providers/preferences_providers.dart';

void main() {
  testWidgets('SpendWise app builds without financial accounts',
      (WidgetTester tester) async {
    final database = AppDatabase.memory();
    addTearDown(database.close);

    await database.into(database.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: 'user_test',
            name: 'Test',
            email: 'test@example.com',
          ),
        );
    await seedSettingsForUser(database, 'user_test');
    await seedCategoriesForUser(database, 'user_test');

    final prefs = UserPreferences.defaults().copyWith(
      hasCompletedOnboarding: true,
      activeUserId: 'user_test',
    );

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        preferencesProvider.overrideWith((ref) => Stream.value(prefs)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SpendWiseApp(),
      ),
    );
    await tester.pump();
    // Advance past splash min-visible delay without pumpAndSettle.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Good morning').evaluate().isNotEmpty ||
            find.text('Good afternoon').evaluate().isNotEmpty ||
            find.text('Good evening').evaluate().isNotEmpty ||
            find.text('Balance').evaluate().isNotEmpty,
        isTrue);
  });
}
