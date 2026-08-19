import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/database/app_database.dart';
import 'package:spendwise/core/database/database_seed.dart';
import 'package:spendwise/data/models/backup_snapshot.dart';
import 'package:spendwise/data/services/backup_service.dart';

void main() {
  test('backup snapshot round-trips JSON', () {
    final snapshot = BackupSnapshot(
      formatVersion: 1,
      exportedAt: DateTime.utc(2026, 8, 19),
      driveEmail: 'you@gmail.com',
      profile: {
        'id': 'u1',
        'name': 'Ada',
        'email': 'ada@example.com',
        'regionCode': 'US',
        'currencyCode': 'USD',
      },
      categories: [
        {'id': 'c1', 'name': 'Food', 'iconName': 'grocery', 'colorValue': 1},
      ],
      expenses: const [],
      budgets: const [],
      recurringExpenses: const [],
      savingGoals: const [],
      savingContributions: const [],
    );

    final restored = BackupSnapshot.fromJson(snapshot.toJson());
    expect(restored.profileEmail, 'ada@example.com');
    expect(restored.categories.single['name'], 'Food');
    expect(restored.driveEmail, 'you@gmail.com');
  });

  test('restore into a user replaces ledger rows', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: 'user_a',
            name: 'Ada',
            email: 'ada@example.com',
          ),
        );
    await seedCategoriesForUser(db, 'user_a');

    final service = BackupService(db);
    final snapshot = BackupSnapshot(
      formatVersion: 1,
      exportedAt: DateTime.now(),
      profile: {
        'id': 'user_b',
        'name': 'Ada restored',
        'email': 'ada@example.com',
        'regionCode': 'PK',
        'currencyCode': 'PKR',
      },
      categories: [
        {
          'id': 'cat_food',
          'name': 'Food',
          'iconName': 'grocery',
          'colorValue': 0xFF10B981,
          'isCustom': true,
        },
      ],
      expenses: [
        {
          'id': 'exp_1',
          'amount': 12.5,
          'categoryId': 'cat_food',
          'note': 'Lunch',
          'date': DateTime(2026, 8, 1).toIso8601String(),
          'paymentMethod': 'cash',
          'isRecurring': false,
        },
      ],
      budgets: const [],
      recurringExpenses: const [],
      savingGoals: const [],
      savingContributions: const [],
    );

    await service.restoreIntoUser(snapshot: snapshot, targetUserId: 'user_a');

    final categories =
        await (db.select(db.categories)..where((t) => t.userId.equals('user_a')))
            .get();
    final expenses =
        await (db.select(db.expenses)..where((t) => t.userId.equals('user_a')))
            .get();
    final profile = await (db.select(db.userProfiles)
          ..where((t) => t.id.equals('user_a')))
        .getSingle();

    expect(categories.map((c) => c.name), contains('Food'));
    expect(expenses, hasLength(1));
    expect(expenses.single.note, 'Lunch');
    expect(profile.name, 'Ada restored');
    expect(profile.currencyCode, 'PKR');
  });
}
