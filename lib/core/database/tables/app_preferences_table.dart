import 'package:drift/drift.dart';

@DataClassName('PreferencesRow')
class AppPreferences extends Table {
  IntColumn get id => integer()();
  TextColumn get themeMode => text()();
  TextColumn get regionCode => text()();
  TextColumn get currencyCode => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
