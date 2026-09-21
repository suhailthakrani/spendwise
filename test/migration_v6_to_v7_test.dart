import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:spendwise/core/database/app_database.dart';
import 'package:spendwise/data/repositories/preferences_repository.dart';
import 'package:sqlite3/sqlite3.dart';

/// Upgrading a real schema-6 database must not change anything the signed-in
/// account can see, and must not hand their settings to a second account.
void main() {
  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('spendwise_migration');
    dbPath = p.join(tempDir.path, 'spendwise.sqlite');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('carries the signed-in account settings into user_settings', () async {
    _writeSchema6(dbPath);

    final db = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(db.close);

    final settings = await (db.select(db.userSettings)
          ..where((t) => t.userId.equals('user_a')))
        .getSingle();

    expect(settings.themeMode, 'system');
    expect(settings.notificationsEnabled, isFalse);
    expect(settings.billRemindersEnabled, isTrue);
    expect(settings.budgetAlertsEnabled, isFalse);
    expect(settings.goalRemindersEnabled, isTrue);
    expect(settings.productUpdatesEnabled, isTrue);
    expect(settings.backupDriveEmail, 'ada@gmail.com');
    expect(settings.backupDriveFileId, 'drive_file_1');
    expect(
      settings.lastBackupAt,
      DateTime.fromMillisecondsSinceEpoch(1755000000 * 1000),
    );
  });

  test('keeps device state and the ledger intact', () async {
    _writeSchema6(dbPath);

    final db = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(db.close);

    final device = await db.select(db.appPreferences).getSingle();
    expect(device.activeUserId, 'user_a');
    expect(device.hasCompletedOnboarding, isTrue);
    expect(device.biometricUnlockEnabled, isTrue);
    expect(device.biometricUserId, 'user_a');
    expect(device.themeMode, 'system');

    final expenses = await db.select(db.expenses).get();
    expect(expenses, hasLength(1));
    expect(expenses.single.note, 'Lunch');
    expect(expenses.single.amount, 12.5);
    expect(expenses.single.userId, 'user_a');

    final categories = await db.select(db.categories).get();
    expect(categories, hasLength(1));
  });

  test('the merged preferences view is unchanged for the active user', () async {
    _writeSchema6(dbPath);

    final db = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(db.close);

    final prefs = await PreferencesRepository(db).getPreferences();

    expect(prefs.activeUserId, 'user_a');
    expect(prefs.themeMode, ThemeMode.system);
    expect(prefs.hasCompletedOnboarding, isTrue);
    expect(prefs.notificationsEnabled, isFalse);
    expect(prefs.billRemindersEnabled, isTrue);
    expect(prefs.budgetAlertsEnabled, isFalse);
    expect(prefs.productUpdatesEnabled, isTrue);
    expect(prefs.backupDriveEmail, 'ada@gmail.com');
    expect(prefs.backupDriveFileId, 'drive_file_1');
    expect(prefs.canUnlockWithBiometrics, isTrue);
  });

  test('a second local account starts from defaults, not user A settings',
      () async {
    _writeSchema6(dbPath);

    final db = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(db.close);

    final settings = await (db.select(db.userSettings)
          ..where((t) => t.userId.equals('user_b')))
        .getSingle();

    expect(settings.notificationsEnabled, isTrue);
    expect(settings.budgetAlertsEnabled, isTrue);
    expect(settings.productUpdatesEnabled, isFalse);
    expect(settings.backupDriveEmail, isNull);
    expect(settings.backupDriveFileId, isNull);
    expect(settings.lastBackupAt, isNull);
    // Only the neutral device theme is inherited, so the app does not change
    // appearance when this account signs in for the first time.
    expect(settings.themeMode, 'system');
  });

  test('drops the moved columns and adds the user-scoped indexes', () async {
    _writeSchema6(dbPath);

    final db = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(db.close);

    final columns = await db
        .customSelect('PRAGMA table_info(app_preferences)')
        .map((row) => row.read<String>('name'))
        .get();
    expect(columns, contains('active_user_id'));
    expect(columns, contains('biometric_user_id'));
    expect(columns, isNot(contains('notifications_enabled')));
    expect(columns, isNot(contains('backup_drive_email')));
    expect(columns, isNot(contains('last_backup_at')));

    final indexes = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
        .map((row) => row.read<String>('name'))
        .get();
    expect(indexes, contains('idx_expenses_user_date'));
    expect(indexes, contains('idx_expenses_user_category'));
    expect(indexes, contains('idx_budgets_user_period'));
    expect(indexes, contains('idx_recurring_user_due'));
    expect(indexes, contains('idx_saving_goals_user_status'));
    expect(indexes, contains('idx_saving_contributions_user_goal'));
  });

  test('a stale session id does not break the upgrade', () async {
    _writeSchema6(dbPath, activeUserId: 'deleted_user');

    final db = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(db.close);

    // No settings row can exist for a profile that is gone, and the upgrade
    // must still complete rather than fail the foreign key.
    final settings = await db.select(db.userSettings).get();
    expect(settings.map((s) => s.userId), isNot(contains('deleted_user')));
    expect(settings, hasLength(2));

    final prefs = await PreferencesRepository(db).getPreferences();
    expect(prefs.activeUserId, 'deleted_user');
    expect(prefs.notificationsEnabled, isTrue);
  });
}

/// Builds the schema exactly as version 6 shipped it, with data for two local
/// profiles, then stamps `user_version = 6` so drift runs the real upgrade.
void _writeSchema6(String path, {String activeUserId = 'user_a'}) {
  final db = sqlite3.open(path);
  try {
    db.execute('''
CREATE TABLE user_profiles (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  password_hash TEXT NOT NULL DEFAULT '',
  password_salt TEXT NOT NULL DEFAULT '',
  region_code TEXT NOT NULL DEFAULT 'US',
  currency_code TEXT NOT NULL DEFAULT 'USD',
  avatar_url TEXT,
  google_id TEXT,
  member_since INTEGER
);
CREATE TABLE categories (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT 'profile_main',
  name TEXT NOT NULL,
  icon_name TEXT NOT NULL,
  color_value INTEGER NOT NULL,
  is_custom INTEGER NOT NULL DEFAULT 0,
  budget_limit REAL
);
CREATE TABLE expenses (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT 'profile_main',
  amount REAL NOT NULL,
  category_id TEXT NOT NULL REFERENCES categories (id),
  note TEXT NOT NULL DEFAULT '',
  date INTEGER NOT NULL,
  payment_method TEXT NOT NULL,
  is_recurring INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE budgets (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT 'profile_main',
  name TEXT NOT NULL,
  limit_amount REAL NOT NULL,
  category_id TEXT REFERENCES categories (id),
  is_monthly INTEGER NOT NULL DEFAULT 1,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL
);
CREATE TABLE recurring_expenses (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT 'profile_main',
  title TEXT NOT NULL,
  amount REAL NOT NULL,
  category_id TEXT NOT NULL REFERENCES categories (id),
  frequency TEXT NOT NULL,
  next_due_date INTEGER NOT NULL,
  payment_method TEXT NOT NULL
);
CREATE TABLE saving_goals (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT 'profile_main',
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  deadline INTEGER,
  monthly_target REAL,
  wishlist_title TEXT,
  wishlist_note TEXT,
  priority INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'active',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
CREATE TABLE saving_contributions (
  id TEXT NOT NULL PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT 'profile_main',
  goal_id TEXT NOT NULL REFERENCES saving_goals (id),
  amount REAL NOT NULL,
  note TEXT NOT NULL DEFAULT '',
  date INTEGER NOT NULL,
  created_at INTEGER NOT NULL
);
CREATE TABLE app_preferences (
  id INTEGER NOT NULL PRIMARY KEY,
  theme_mode TEXT NOT NULL,
  has_completed_onboarding INTEGER NOT NULL DEFAULT 0,
  active_user_id TEXT,
  notifications_enabled INTEGER NOT NULL DEFAULT 1,
  bill_reminders_enabled INTEGER NOT NULL DEFAULT 1,
  budget_alerts_enabled INTEGER NOT NULL DEFAULT 1,
  goal_reminders_enabled INTEGER NOT NULL DEFAULT 1,
  product_updates_enabled INTEGER NOT NULL DEFAULT 0,
  backup_drive_email TEXT,
  last_backup_at INTEGER,
  backup_drive_file_id TEXT,
  biometric_unlock_enabled INTEGER NOT NULL DEFAULT 0,
  biometric_user_id TEXT
);
''');

    db.execute(
      "INSERT INTO user_profiles (id, name, email) VALUES "
      "('user_a', 'Ada', 'ada@example.com'), "
      "('user_b', 'Grace', 'grace@example.com')",
    );
    db.execute(
      'INSERT INTO categories (id, user_id, name, icon_name, color_value) '
      "VALUES ('cat_food', 'user_a', 'Food', 'grocery', 42)",
    );
    db.execute(
      'INSERT INTO expenses '
      '(id, user_id, amount, category_id, note, date, payment_method) VALUES '
      "('exp_1', 'user_a', 12.5, 'cat_food', 'Lunch', 1754000000, 'cash')",
    );
    db.execute(
      'INSERT INTO app_preferences '
      '(id, theme_mode, has_completed_onboarding, active_user_id, '
      'notifications_enabled, bill_reminders_enabled, budget_alerts_enabled, '
      'goal_reminders_enabled, product_updates_enabled, backup_drive_email, '
      'last_backup_at, backup_drive_file_id, biometric_unlock_enabled, '
      'biometric_user_id) VALUES '
      "(1, 'system', 1, '$activeUserId', 0, 1, 0, 1, 1, 'ada@gmail.com', "
      "1755000000, 'drive_file_1', 1, 'user_a')",
    );

    db.execute('PRAGMA user_version = 6');
  } finally {
    db.dispose();
  }
}
