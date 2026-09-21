import 'package:drift/drift.dart';

/// Device-wide state, one row per install.
///
/// Per-account settings live in `UserSettings` — keep this table limited to
/// things that are true of the device rather than of a signed-in account.
@DataClassName('PreferencesRow')
class AppPreferences extends Table {
  IntColumn get id => integer()();

  /// Theme used before any account is signed in (splash, onboarding, sign-in).
  /// Mirrors the signed-in account's choice so the next cold start matches.
  TextColumn get themeMode => text()();
  BoolColumn get hasCompletedOnboarding =>
      boolean().withDefault(const Constant(false))();
  TextColumn get activeUserId => text().nullable()();

  /// Which single local account this device's biometrics unlock.
  BoolColumn get biometricUnlockEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get biometricUserId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
