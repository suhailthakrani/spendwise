import 'package:drift/drift.dart';

@DataClassName('PreferencesRow')
class AppPreferences extends Table {
  IntColumn get id => integer()();
  TextColumn get themeMode => text()();
  BoolColumn get hasCompletedOnboarding =>
      boolean().withDefault(const Constant(false))();
  TextColumn get activeUserId => text().nullable()();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get billRemindersEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get budgetAlertsEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get goalRemindersEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get productUpdatesEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get backupDriveEmail => text().nullable()();
  DateTimeColumn get lastBackupAt => dateTime().nullable()();
  TextColumn get backupDriveFileId => text().nullable()();
  BoolColumn get biometricUnlockEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get biometricUserId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
