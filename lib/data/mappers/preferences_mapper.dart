import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../models/user_preferences.dart';

abstract final class PreferencesMapper {
  static const preferencesId = 1;

  static UserPreferences fromRow(PreferencesRow row) {
    return UserPreferences(
      themeMode: ThemeMode.values.byName(row.themeMode),
      hasCompletedOnboarding: row.hasCompletedOnboarding,
      activeUserId: row.activeUserId,
      notificationsEnabled: row.notificationsEnabled,
      billRemindersEnabled: row.billRemindersEnabled,
      budgetAlertsEnabled: row.budgetAlertsEnabled,
      goalRemindersEnabled: row.goalRemindersEnabled,
      productUpdatesEnabled: row.productUpdatesEnabled,
      backupDriveEmail: row.backupDriveEmail,
      lastBackupAt: row.lastBackupAt,
      backupDriveFileId: row.backupDriveFileId,
      biometricUnlockEnabled: row.biometricUnlockEnabled,
      biometricUserId: row.biometricUserId,
    );
  }

  static AppPreferencesCompanion toCompanion(UserPreferences preferences) {
    return AppPreferencesCompanion(
      id: const Value(preferencesId),
      themeMode: Value(preferences.themeMode.name),
      hasCompletedOnboarding: Value(preferences.hasCompletedOnboarding),
      activeUserId: Value(preferences.activeUserId),
      notificationsEnabled: Value(preferences.notificationsEnabled),
      billRemindersEnabled: Value(preferences.billRemindersEnabled),
      budgetAlertsEnabled: Value(preferences.budgetAlertsEnabled),
      goalRemindersEnabled: Value(preferences.goalRemindersEnabled),
      productUpdatesEnabled: Value(preferences.productUpdatesEnabled),
      backupDriveEmail: Value(preferences.backupDriveEmail),
      lastBackupAt: Value(preferences.lastBackupAt),
      backupDriveFileId: Value(preferences.backupDriveFileId),
      biometricUnlockEnabled: Value(preferences.biometricUnlockEnabled),
      biometricUserId: Value(preferences.biometricUserId),
    );
  }
}
