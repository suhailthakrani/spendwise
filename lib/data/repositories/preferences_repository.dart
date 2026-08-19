import 'package:flutter/material.dart';
import 'package:spendwise/data/mappers/preferences_mapper.dart';
import 'package:spendwise/data/models/user_preferences.dart';

import '../../core/database/app_database.dart';

class PreferencesRepository {
  PreferencesRepository(this._db);

  final AppDatabase _db;

  Stream<UserPreferences> watchPreferences() {
    return (_db.select(_db.appPreferences)
          ..where((t) => t.id.equals(PreferencesMapper.preferencesId)))
        .watchSingleOrNull()
        .map((row) {
      if (row == null) return UserPreferences.defaults();
      return PreferencesMapper.fromRow(row);
    });
  }

  Future<UserPreferences> getPreferences() async {
    final row = await (_db.select(_db.appPreferences)
          ..where((t) => t.id.equals(PreferencesMapper.preferencesId)))
        .getSingleOrNull();
    return row == null
        ? UserPreferences.defaults()
        : PreferencesMapper.fromRow(row);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = await getPreferences();
    await _upsert(current.copyWith(themeMode: mode));
  }

  Future<void> completeOnboarding() async {
    final current = await getPreferences();
    await _upsert(current.copyWith(hasCompletedOnboarding: true));
  }

  Future<void> setActiveUserId(String userId) async {
    final current = await getPreferences();
    await _upsert(current.copyWith(activeUserId: userId));
  }

  Future<void> clearSession() async {
    final current = await getPreferences();
    await _upsert(current.copyWith(clearActiveUserId: true));
  }

  Future<void> setBackupDriveEmail(String? email) async {
    final current = await getPreferences();
    final normalized = email?.trim().toLowerCase();
    final emailChanged = (normalized ?? '') != (current.backupDriveEmail ?? '');
    await _upsert(
      current.copyWith(
        backupDriveEmail: normalized,
        clearBackupDriveEmail: normalized == null || normalized.isEmpty,
        clearBackupDriveFileId: emailChanged,
      ),
    );
  }

  Future<void> setLastBackup({
    required DateTime at,
    String? driveFileId,
  }) async {
    final current = await getPreferences();
    await _upsert(
      current.copyWith(
        lastBackupAt: at,
        backupDriveFileId: driveFileId,
        clearBackupDriveFileId: driveFileId == null || driveFileId.isEmpty,
      ),
    );
  }

  Future<void> setBiometricUnlock({
    required bool enabled,
    String? userId,
  }) async {
    final current = await getPreferences();
    await _upsert(
      current.copyWith(
        biometricUnlockEnabled: enabled,
        biometricUserId: enabled ? userId : null,
        clearBiometricUserId: !enabled || userId == null || userId.isEmpty,
      ),
    );
  }

  Future<void> setNotificationSettings({
    bool? notificationsEnabled,
    bool? billRemindersEnabled,
    bool? budgetAlertsEnabled,
    bool? goalRemindersEnabled,
    bool? productUpdatesEnabled,
  }) async {
    final current = await getPreferences();
    await _upsert(
      current.copyWith(
        notificationsEnabled: notificationsEnabled,
        billRemindersEnabled: billRemindersEnabled,
        budgetAlertsEnabled: budgetAlertsEnabled,
        goalRemindersEnabled: goalRemindersEnabled,
        productUpdatesEnabled: productUpdatesEnabled,
      ),
    );
  }

  Future<void> _upsert(UserPreferences preferences) async {
    await _db.into(_db.appPreferences).insertOnConflictUpdate(
          PreferencesMapper.toCompanion(preferences),
        );
  }
}
