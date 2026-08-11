import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'database_seed.dart';
import 'tables/app_preferences_table.dart';
import 'tables/budgets_table.dart';
import 'tables/categories_table.dart';
import 'tables/expenses_table.dart';
import 'tables/recurring_expenses_table.dart';
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// In-memory database for tests.
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          await seedDatabase(this);
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            // Wipe leftover demo/sample transactional data from early builds.
            await clearUserGeneratedData();
          }
          if (from < 4) {
            await ensureDefaultCategories();
          }
        },
      );

  /// Removes expenses, budgets, and recurring items; resets profile.
  /// Keeps categories and app preferences.
  Future<void> clearUserGeneratedData() async {
    await transaction(() async {
      await delete(expenses).go();
      await delete(budgets).go();
      await delete(recurringExpenses).go();
      await (update(categories)).write(
        const CategoriesCompanion(budgetLimit: Value(null)),
      );
      await (update(userProfiles)).write(
        const UserProfilesCompanion(
          name: Value(''),
          email: Value(''),
          memberSince: Value(null),
        ),
      );
    });
  }

  /// Inserts any missing starter categories (safe for existing installs).
  Future<void> ensureDefaultCategories() async {
    await ensureStarterCategories(this);
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File(p.join(directory.path, 'spendwise.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
