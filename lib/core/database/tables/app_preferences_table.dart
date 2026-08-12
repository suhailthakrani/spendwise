import 'package:drift/drift.dart';

@DataClassName('PreferencesRow')
class AppPreferences extends Table {
  IntColumn get id => integer()();
  TextColumn get themeMode => text()();
  BoolColumn get hasCompletedOnboarding =>
      boolean().withDefault(const Constant(false))();
  TextColumn get activeUserId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
