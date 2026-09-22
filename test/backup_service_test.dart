import 'package:drift/drift.dart' hide isNull;
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

    // A version 1 file has no settings, so the account gets defaults rather
    // than nothing at all.
    final settings = await (db.select(db.userSettings)
          ..where((t) => t.userId.equals('user_a')))
        .getSingle();
    expect(settings.notificationsEnabled, isTrue);
  });

  test('a snapshot carries account settings but not Drive linkage', () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: 'user_a',
            name: 'Ada',
            email: 'ada@example.com',
          ),
        );
    await seedSettingsForUser(db, 'user_a');
    await (db.update(db.userSettings)
          ..where((t) => t.userId.equals('user_a')))
        .write(
      const UserSettingsCompanion(
        themeMode: Value('system'),
        budgetAlertsEnabled: Value(false),
        backupDriveEmail: Value('ada@gmail.com'),
        backupDriveFileId: Value('drive_file_1'),
      ),
    );

    final snapshot = await BackupService(db).createSnapshot(userId: 'user_a');

    expect(snapshot.formatVersion, 3);
    expect(snapshot.settings['themeMode'], 'system');
    expect(snapshot.settings['budgetAlertsEnabled'], isFalse);
    expect(snapshot.settings['notificationsEnabled'], isTrue);
    expect(snapshot.settings.containsKey('backupDriveEmail'), isFalse);
    expect(snapshot.settings.containsKey('backupDriveFileId'), isFalse);
  });

  test('restoring applies settings and keeps this device Drive linkage',
      () async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: 'user_b',
            name: 'Grace',
            email: 'grace@example.com',
          ),
        );
    await seedSettingsForUser(db, 'user_b');
    await (db.update(db.userSettings)
          ..where((t) => t.userId.equals('user_b')))
        .write(
      const UserSettingsCompanion(
        backupDriveEmail: Value('grace@gmail.com'),
        backupDriveFileId: Value('device_file'),
      ),
    );

    final snapshot = BackupSnapshot(
      formatVersion: 2,
      exportedAt: DateTime.now(),
      profile: {
        'id': 'user_b',
        'name': 'Grace',
        'email': 'grace@example.com',
      },
      settings: const {
        'themeMode': 'system',
        'billRemindersEnabled': false,
        'productUpdatesEnabled': true,
      },
      categories: const [],
      expenses: const [],
      budgets: const [],
      recurringExpenses: const [],
      savingGoals: const [],
      savingContributions: const [],
    );

    await BackupService(db)
        .restoreIntoUser(snapshot: snapshot, targetUserId: 'user_b');

    final settings = await (db.select(db.userSettings)
          ..where((t) => t.userId.equals('user_b')))
        .getSingle();
    expect(settings.themeMode, 'system');
    expect(settings.billRemindersEnabled, isFalse);
    expect(settings.productUpdatesEnabled, isTrue);
    expect(settings.backupDriveEmail, 'grace@gmail.com');
    expect(settings.backupDriveFileId, 'device_file');
  });
}
