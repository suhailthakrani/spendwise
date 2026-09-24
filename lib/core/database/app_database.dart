import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

import 'database_key_store.dart';
import 'database_seed.dart';
import 'tables/app_preferences_table.dart';
import 'tables/budgets_table.dart';
import 'tables/categories_table.dart';
import 'tables/envelopes_table.dart';
import 'tables/expenses_table.dart';
import 'tables/money_logs_table.dart';
import 'tables/recurring_expenses_table.dart';
import 'tables/saving_contributions_table.dart';
import 'tables/saving_goals_table.dart';
import 'tables/transaction_templates_table.dart';
import 'tables/user_profiles_table.dart';
import 'tables/user_settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Expenses,
    Budgets,
    RecurringExpenses,
    AppPreferences,
    UserProfiles,
    UserSettings,
    SavingGoals,
    SavingContributions,
    TransactionTemplates,
    Envelopes,
    MoneyLogs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory database for tests (unencrypted).
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          await seedDatabase(this);
          await _createExpensesFts();
        },
        onUpgrade: (migrator, from, to) async {
          // Steps 2 and 3 use raw SQL on purpose: the columns they add were
          // later moved to `user_settings` (step 7), so they no longer exist on
          // the Dart table and cannot be referenced via `addColumn`. A device
          // upgrading from an old version still needs them to exist before
          // step 7 can copy their values across.
          if (from < 2) {
            for (final column in [
              'notifications_enabled',
              'bill_reminders_enabled',
              'budget_alerts_enabled',
              'goal_reminders_enabled',
            ]) {
              await customStatement(
                'ALTER TABLE app_preferences ADD COLUMN $column '
                'INTEGER NOT NULL DEFAULT 1',
              );
            }
            await customStatement(
              'ALTER TABLE app_preferences ADD COLUMN product_updates_enabled '
              'INTEGER NOT NULL DEFAULT 0',
            );
          }
          if (from < 3) {
            await customStatement(
              'ALTER TABLE app_preferences ADD COLUMN backup_drive_email TEXT',
            );
            await customStatement(
              'ALTER TABLE app_preferences ADD COLUMN last_backup_at INTEGER',
            );
            await customStatement(
              'ALTER TABLE app_preferences ADD COLUMN backup_drive_file_id TEXT',
            );
            await migrator.addColumn(
              appPreferences,
              appPreferences.biometricUnlockEnabled,
            );
            await migrator.addColumn(
              appPreferences,
              appPreferences.biometricUserId,
            );
          }
          if (from < 4) {
            await migrator.addColumn(userProfiles, userProfiles.googleId);
          }
          if (from < 5) {
            final now = DateTime.now();
            // Existing budgets become the current month's budgets.
            await customStatement(
              'ALTER TABLE budgets ADD COLUMN year INTEGER NOT NULL '
              'DEFAULT ${now.year}',
            );
            await customStatement(
              'ALTER TABLE budgets ADD COLUMN month INTEGER NOT NULL '
              'DEFAULT ${now.month}',
            );
          }
          if (from < 6) {
            await customStatement(
              "UPDATE app_preferences SET theme_mode = 'dark' "
              "WHERE theme_mode = 'light'",
            );
          }
          if (from < 7) {
            await _moveSettingsToUsers(migrator);
          }
          if (from < 8) {
            await _addLedgerTypes();
          }
          if (from < 9) {
            await _addCaptureAnalyticsBudgetV2(migrator);
          }
          if (from < 10) {
            await migrator.createTable(moneyLogs);
          }
        },
      );

  /// Capture defaults, templates, tags/attachments, budget periods, envelopes,
  /// dashboard layout, and FTS for search v2.
  Future<void> _addCaptureAnalyticsBudgetV2(Migrator migrator) async {
    await migrator.createTable(transactionTemplates);
    await migrator.createTable(envelopes);

    await _addColumnIfAbsent(migrator, expenses, expenses.tags);
    await _addColumnIfAbsent(migrator, expenses, expenses.attachmentPath);
    await _addColumnIfAbsent(
      migrator,
      recurringExpenses,
      recurringExpenses.entryType,
    );
    await _addColumnIfAbsent(
      migrator,
      recurringExpenses,
      recurringExpenses.autoPost,
    );
    await _addColumnIfAbsent(migrator, budgets, budgets.periodType);
    await _addColumnIfAbsent(migrator, budgets, budgets.startDate);
    await _addColumnIfAbsent(migrator, budgets, budgets.endDate);
    await _addColumnIfAbsent(migrator, budgets, budgets.rolloverEnabled);
    await _addColumnIfAbsent(migrator, budgets, budgets.rolloverAmount);
    await _addColumnIfAbsent(migrator, budgets, budgets.isSpendingLimit);

    await _addColumnIfAbsent(
      migrator,
      userSettings,
      userSettings.defaultCategoryId,
    );
    await _addColumnIfAbsent(
      migrator,
      userSettings,
      userSettings.lastUsedCategoryId,
    );
    await _addColumnIfAbsent(
      migrator,
      userSettings,
      userSettings.dashboardLayoutJson,
    );
    await _addColumnIfAbsent(
      migrator,
      userSettings,
      userSettings.analyticsPeriod,
    );
    await _addColumnIfAbsent(
      migrator,
      userSettings,
      userSettings.quickActionsJson,
    );

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_templates_user '
      'ON transaction_templates (user_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_envelopes_user '
      'ON envelopes (user_id)',
    );

    await _createExpensesFts();
  }

  Future<void> _createExpensesFts() async {
    await customStatement('''
CREATE VIRTUAL TABLE IF NOT EXISTS expenses_fts USING fts5(
  note, tags, content='expenses', content_rowid='rowid'
)
''');
    await customStatement('''
INSERT INTO expenses_fts(expenses_fts) VALUES('rebuild')
''');
  }

  Future<void> _addColumnIfAbsent(
    Migrator migrator,
    TableInfo table,
    GeneratedColumn column,
  ) async {
    final existing = await customSelect(
      'PRAGMA table_info(${table.actualTableName})',
    ).get();
    final names = {
      for (final row in existing) row.read<String>('name'),
    };
    if (names.contains(column.name)) return;
    await migrator.addColumn(table, column);
  }

  /// Income/expense discriminator + Income category. No wallets — never shipped.
  Future<void> _addLedgerTypes() async {
    final profiles = await select(userProfiles).get();
    for (final profile in profiles) {
      await seedIncomeCategoryForUser(this, profile.id);
    }

    await _addRawColumnIfAbsent(
      'expenses',
      'type',
      "TEXT NOT NULL DEFAULT 'expense'",
    );

    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_expenses_user_type '
      'ON expenses (user_id, type)',
    );
  }

  Future<void> _addRawColumnIfAbsent(
    String tableName,
    String columnName,
    String typeSql,
  ) async {
    final existing = await customSelect(
      'PRAGMA table_info($tableName)',
    ).get();
    final names = {
      for (final row in existing) row.read<String>('name'),
    };
    if (names.contains(columnName)) return;
    await customStatement(
      'ALTER TABLE $tableName ADD COLUMN $columnName $typeSql',
    );
  }

  /// Splits the single device preferences row into device state plus per-account
  /// settings, so a second account can never inherit the first one's
  /// notification choices or Google Drive backup target.
  ///
  /// The signed-in account keeps exactly what it had; any other local profile
  /// starts from defaults.
  Future<void> _moveSettingsToUsers(Migrator migrator) async {
    await migrator.createTable(userSettings);

    // Carry the current settings over to whoever is signed in. The profile
    // check keeps a stale session id from failing the foreign key.
    await customStatement(
      'INSERT OR REPLACE INTO user_settings '
      '(user_id, theme_mode, notifications_enabled, bill_reminders_enabled, '
      'budget_alerts_enabled, goal_reminders_enabled, product_updates_enabled, '
      'backup_drive_email, backup_drive_file_id, last_backup_at) '
      'SELECT p.active_user_id, p.theme_mode, p.notifications_enabled, '
      'p.bill_reminders_enabled, p.budget_alerts_enabled, '
      'p.goal_reminders_enabled, p.product_updates_enabled, '
      'p.backup_drive_email, p.backup_drive_file_id, p.last_backup_at '
      'FROM app_preferences p '
      "WHERE p.active_user_id IS NOT NULL AND p.active_user_id <> '' "
      'AND p.active_user_id IN (SELECT id FROM user_profiles)',
    );

    // Every other profile gets defaults, inheriting only the device theme so
    // the app does not visibly change appearance on first sign-in.
    await customStatement(
      'INSERT OR IGNORE INTO user_settings (user_id, theme_mode) '
      'SELECT u.id, COALESCE('
      '(SELECT p.theme_mode FROM app_preferences p LIMIT 1), '
      "'dark') FROM user_profiles u",
    );

    // Drops the columns that moved to user_settings, copying the rest.
    await migrator.alterTable(TableMigration(appPreferences));

    await _createUserScopedIndexes();
  }

  /// Every read filters by `user_id`; these keep that cheap as history grows.
  /// Named to match the `@TableIndex` annotations used for fresh installs.
  Future<void> _createUserScopedIndexes() async {
    const statements = [
      'CREATE INDEX IF NOT EXISTS idx_expenses_user_date '
          'ON expenses (user_id, date)',
      'CREATE INDEX IF NOT EXISTS idx_expenses_user_category '
          'ON expenses (user_id, category_id)',
      'CREATE INDEX IF NOT EXISTS idx_budgets_user_period '
          'ON budgets (user_id, year, month)',
      'CREATE INDEX IF NOT EXISTS idx_categories_user '
          'ON categories (user_id)',
      'CREATE INDEX IF NOT EXISTS idx_recurring_user_due '
          'ON recurring_expenses (user_id, next_due_date)',
      'CREATE INDEX IF NOT EXISTS idx_saving_goals_user_status '
          'ON saving_goals (user_id, status)',
      'CREATE INDEX IF NOT EXISTS idx_saving_contributions_user_goal '
          'ON saving_contributions (user_id, goal_id)',
    ];
    for (final statement in statements) {
      await customStatement(statement);
    }
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      await _configureSqlCipherDynamicLibrary();

      final credentials = await DatabaseKeyStore.obtain();
      final file = File(credentials.filePath);
      await file.parent.create(recursive: true);

      // Drop leftover plaintext DBs from earlier builds (best-effort).
      await _deleteLegacyPlaintextFiles();

      // Open on this isolate so the Keystore-backed key stays in-process
      // (avoids isolate send issues with createInBackground + secret capture).
      return NativeDatabase(
        file,
        setup: (rawDb) {
          // Fail closed if SQLCipher is not linked (pragma is a no-op on stock SQLite).
          final cipher = rawDb.select('PRAGMA cipher_version;');
          if (cipher.isEmpty) {
            throw StateError(
              'SQLCipher is unavailable — refusing to open a plaintext database.',
            );
          }

          // Hex key form avoids quote-escaping issues in the passphrase.
          rawDb.execute("PRAGMA key = \"x'${credentials.hexKey}'\";");
          rawDb.execute('PRAGMA foreign_keys = ON;');
          rawDb.execute('PRAGMA journal_mode = WAL;');
        },
      );
    });
  }

  static Future<void> _configureSqlCipherDynamicLibrary() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
    }
  }

  static Future<void> _deleteLegacyPlaintextFiles() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      for (final name in [
        'spendwise.sqlite',
        'spendwise_v2.sqlite',
        'spendwise.sqlite-wal',
        'spendwise.sqlite-shm',
        'spendwise_v2.sqlite-wal',
        'spendwise_v2.sqlite-shm',
      ]) {
        final f = File(p.join(docs.path, name));
        if (await f.exists()) {
          await f.delete();
        }
      }
    } catch (_) {
      // Ignore — cleanup is best-effort.
    }
  }
}
