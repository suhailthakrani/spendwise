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
import 'tables/expenses_table.dart';
import 'tables/recurring_expenses_table.dart';
import 'tables/saving_contributions_table.dart';
import 'tables/saving_goals_table.dart';
import 'tables/user_profiles_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Categories,
    Expenses,
    Budgets,
    RecurringExpenses,
    AppPreferences,
    UserProfiles,
    SavingGoals,
    SavingContributions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory database for tests (unencrypted).
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  /// Fresh encrypted schema. No upgrade path — new installs only.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          await seedDatabase(this);
        },
      );

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
