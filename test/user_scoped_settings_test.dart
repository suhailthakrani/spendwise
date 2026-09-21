import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/database/app_database.dart';
import 'package:spendwise/data/repositories/preferences_repository.dart';
import 'package:spendwise/data/repositories/user_profile_repository.dart';

/// Settings must belong to an account, not to the device. Two accounts on the
/// same install never see each other's theme, reminders or Drive backup.
void main() {
  late AppDatabase db;
  late PreferencesRepository preferences;

  setUp(() async {
    db = AppDatabase.memory();
    preferences = PreferencesRepository(db);
    await db.batch((batch) {
      batch.insertAll(db.userProfiles, [
        UserProfilesCompanion.insert(
          id: 'user_a',
          name: 'Ada',
          email: 'ada@example.com',
        ),
        UserProfilesCompanion.insert(
          id: 'user_b',
          name: 'Grace',
          email: 'grace@example.com',
        ),
      ]);
    });
  });

  tearDown(() => db.close());

  test('signing in creates that account its own settings row', () async {
    await preferences.setActiveUserId('user_a');

    final settings = await (db.select(db.userSettings)
          ..where((t) => t.userId.equals('user_a')))
        .getSingle();
    expect(settings.notificationsEnabled, isTrue);
    expect(settings.backupDriveEmail, isNull);
  });

  test('account settings do not leak to the other account', () async {
    await preferences.setActiveUserId('user_a');
    await preferences.setThemeMode(ThemeMode.system);
    await preferences.setNotificationSettings(
      billRemindersEnabled: false,
      productUpdatesEnabled: true,
    );
    await preferences.setBackupDriveEmail('ada@gmail.com');
    await preferences.setLastBackup(at: DateTime(2026, 9, 1), driveFileId: 'f1');

    await preferences.setActiveUserId('user_b');
    final forB = await preferences.getPreferences();

    expect(forB.activeUserId, 'user_b');
    expect(forB.billRemindersEnabled, isTrue);
    expect(forB.productUpdatesEnabled, isFalse);
    expect(forB.backupDriveEmail, isNull);
    expect(forB.backupDriveFileId, isNull);
    expect(forB.lastBackupAt, isNull);

    await preferences.setActiveUserId('user_a');
    final forA = await preferences.getPreferences();

    expect(forA.themeMode, ThemeMode.system);
    expect(forA.billRemindersEnabled, isFalse);
    expect(forA.productUpdatesEnabled, isTrue);
    expect(forA.backupDriveEmail, 'ada@gmail.com');
    expect(forA.backupDriveFileId, 'f1');
    expect(forA.lastBackupAt, DateTime(2026, 9, 1));
  });

  test('changing the Drive account forgets the remembered file', () async {
    await preferences.setActiveUserId('user_a');
    await preferences.setBackupDriveEmail('ada@gmail.com');
    await preferences.setLastBackup(at: DateTime(2026, 9, 1), driveFileId: 'f1');

    await preferences.setBackupDriveEmail('other@gmail.com');

    final prefs = await preferences.getPreferences();
    expect(prefs.backupDriveEmail, 'other@gmail.com');
    expect(prefs.backupDriveFileId, isNull);
  });

  test('signed out, the view falls back to the device theme and defaults',
      () async {
    await preferences.setActiveUserId('user_a');
    await preferences.setThemeMode(ThemeMode.system);
    await preferences.setNotificationSettings(notificationsEnabled: false);

    await preferences.clearSession();
    final prefs = await preferences.getPreferences();

    expect(prefs.isSignedIn, isFalse);
    // Device mirror keeps the sign-in screen looking like the last session.
    expect(prefs.themeMode, ThemeMode.system);
    expect(prefs.notificationsEnabled, isTrue);
  });

  test('biometric unlock stays device level across account switches', () async {
    await preferences.setActiveUserId('user_a');
    await preferences.setBiometricUnlock(enabled: true, userId: 'user_a');

    await preferences.setActiveUserId('user_b');
    final prefs = await preferences.getPreferences();

    expect(prefs.biometricUnlockEnabled, isTrue);
    expect(prefs.biometricUserId, 'user_a');
    expect(prefs.canUnlockWithBiometrics, isTrue);
  });

  test('closing an account removes its settings and leaves the other alone',
      () async {
    final profiles = UserProfileRepository(db);
    final created = await profiles.signUp(
      name: 'Lin',
      email: 'lin@example.com',
      password: 'secret123',
      regionCode: 'US',
      currencyCode: 'USD',
    );
    await preferences.setActiveUserId(created.id);
    await preferences.setNotificationSettings(budgetAlertsEnabled: false);

    await profiles.deleteAccount(userId: created.id, password: 'secret123');

    final remaining = await db.select(db.userSettings).get();
    expect(remaining.map((s) => s.userId), isNot(contains(created.id)));
  });
}
