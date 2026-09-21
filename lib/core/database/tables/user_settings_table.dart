import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

/// Settings that belong to one local account.
///
/// Anything here must be per-user: two accounts on the same device get their
/// own theme, notification choices and Drive backup target. Device-wide state
/// (active session, onboarding, biometric binding) stays in [AppPreferences].
@DataClassName('UserSettingsRow')
class UserSettings extends Table {
  TextColumn get userId => text().references(UserProfiles, #id)();
  TextColumn get themeMode => text().withDefault(const Constant('dark'))();
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
  TextColumn get backupDriveFileId => text().nullable()();
  DateTimeColumn get lastBackupAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}
