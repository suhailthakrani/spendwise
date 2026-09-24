import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:spendwise/core/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

/// Upgrading schema 8 → 9 must add capture/analytics/budget v2 columns + tables.
void main() {
  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('spendwise_v9');
    dbPath = p.join(tempDir.path, 'spendwise.sqlite');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('v8 upgrade creates templates, envelopes, and new columns', () async {
    _writeSchema8(dbPath);

    final db = AppDatabase(NativeDatabase(File(dbPath)));
    addTearDown(db.close);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data['user_version'], greaterThanOrEqualTo(9));

    final templateCols = await db
        .customSelect('PRAGMA table_info(transaction_templates)')
        .get();
    expect(templateCols, isNotEmpty);

    final envelopeCols =
        await db.customSelect('PRAGMA table_info(envelopes)').get();
    expect(envelopeCols, isNotEmpty);

    final expenseCols =
        await db.customSelect('PRAGMA table_info(expenses)').get();
    final expenseNames = expenseCols.map((r) => r.data['name']).toSet();
    expect(expenseNames, containsAll(['tags', 'attachment_path']));

    final accountsTable = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'accounts'",
        )
        .get();
    expect(accountsTable, isEmpty);

    final budgetCols =
        await db.customSelect('PRAGMA table_info(budgets)').get();
    final budgetNames = budgetCols.map((r) => r.data['name']).toSet();
    expect(
      budgetNames,
      containsAll([
        'period_type',
        'start_date',
        'end_date',
        'rollover_enabled',
        'rollover_amount',
        'is_spending_limit',
      ]),
    );
    expect(budgetNames, isNot(contains('account_id')));

    final recurringCols =
        await db.customSelect('PRAGMA table_info(recurring_expenses)').get();
    final recurringNames = recurringCols.map((r) => r.data['name']).toSet();
    expect(recurringNames, containsAll(['entry_type', 'auto_post']));
    expect(recurringNames, isNot(contains('account_id')));

    final settingsCols =
        await db.customSelect('PRAGMA table_info(user_settings)').get();
    final settingsNames = settingsCols.map((r) => r.data['name']).toSet();
    expect(
      settingsNames,
      containsAll([
        'default_category_id',
        'last_used_category_id',
        'dashboard_layout_json',
        'analytics_period',
        'quick_actions_json',
      ]),
    );
    expect(settingsNames, isNot(contains('default_account_id')));

    expect(expenseNames, isNot(contains('account_id')));
    expect(expenseNames, isNot(contains('to_account_id')));

    final expenses =
        await (db.select(db.expenses)..where((t) => t.userId.equals('user_a')))
            .get();
    expect(expenses, hasLength(1));
    expect(expenses.single.amount, 12.5);
    expect(expenses.single.note, 'Lunch');
    expect(expenses.single.type, 'expense');
  });
}

void _writeSchema8(String path) {
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
CREATE TABLE user_settings (
  user_id TEXT NOT NULL PRIMARY KEY REFERENCES user_profiles (id),
  theme_mode TEXT NOT NULL DEFAULT 'dark',
  notifications_enabled INTEGER NOT NULL DEFAULT 1,
  bill_reminders_enabled INTEGER NOT NULL DEFAULT 1,
  budget_alerts_enabled INTEGER NOT NULL DEFAULT 1,
  goal_reminders_enabled INTEGER NOT NULL DEFAULT 1,
  product_updates_enabled INTEGER NOT NULL DEFAULT 0,
  backup_drive_email TEXT,
  backup_drive_file_id TEXT,
  last_backup_at INTEGER
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
  is_recurring INTEGER NOT NULL DEFAULT 0,
  type TEXT NOT NULL DEFAULT 'expense'
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
  biometric_unlock_enabled INTEGER NOT NULL DEFAULT 0,
  biometric_user_id TEXT
);
''');

    db.execute(
      "INSERT INTO user_profiles (id, name, email) VALUES "
      "('user_a', 'Ada', 'ada@example.com')",
    );
    db.execute(
      "INSERT INTO user_settings (user_id) VALUES ('user_a')",
    );
    db.execute(
      'INSERT INTO categories (id, user_id, name, icon_name, color_value) '
      "VALUES ('cat_food', 'user_a', 'Food', 'grocery', 42)",
    );
    db.execute(
      'INSERT INTO expenses '
      '(id, user_id, amount, category_id, note, date, payment_method, type) VALUES '
      "('exp_1', 'user_a', 12.5, 'cat_food', 'Lunch', 1754000000, 'cash', 'expense')",
    );
    db.execute(
      "INSERT INTO app_preferences (id, theme_mode, has_completed_onboarding, "
      "active_user_id) VALUES (1, 'dark', 1, 'user_a')",
    );
    db.execute('PRAGMA user_version = 8');
  } finally {
    db.dispose();
  }
}
