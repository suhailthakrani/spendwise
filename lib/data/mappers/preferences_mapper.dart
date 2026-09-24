import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../models/user_preferences.dart';

abstract final class PreferencesMapper {
  static const preferencesId = 1;

  /// Merges device state with the signed-in account's settings. [settings] is
  /// null when nobody is signed in, in which case account fields fall back to
  /// defaults and the theme comes from the device row.
  static UserPreferences fromRows({
    required PreferencesRow device,
    UserSettingsRow? settings,
  }) {
    final defaults = UserPreferences.defaults();
    return UserPreferences(
      themeMode: _themeMode(settings?.themeMode ?? device.themeMode),
      hasCompletedOnboarding: device.hasCompletedOnboarding,
      activeUserId: device.activeUserId,
      notificationsEnabled:
          settings?.notificationsEnabled ?? defaults.notificationsEnabled,
      billRemindersEnabled:
          settings?.billRemindersEnabled ?? defaults.billRemindersEnabled,
      budgetAlertsEnabled:
          settings?.budgetAlertsEnabled ?? defaults.budgetAlertsEnabled,
      goalRemindersEnabled:
          settings?.goalRemindersEnabled ?? defaults.goalRemindersEnabled,
      productUpdatesEnabled:
          settings?.productUpdatesEnabled ?? defaults.productUpdatesEnabled,
      backupDriveEmail: settings?.backupDriveEmail,
      lastBackupAt: settings?.lastBackupAt,
      backupDriveFileId: settings?.backupDriveFileId,
      biometricUnlockEnabled: device.biometricUnlockEnabled,
      biometricUserId: device.biometricUserId,
      defaultCategoryId: settings?.defaultCategoryId,
      lastUsedCategoryId: settings?.lastUsedCategoryId,
      dashboardLayoutJson:
          settings?.dashboardLayoutJson ?? defaults.dashboardLayoutJson,
      analyticsPeriod: settings?.analyticsPeriod ?? defaults.analyticsPeriod,
      quickActionsJson:
          settings?.quickActionsJson ?? defaults.quickActionsJson,
    );
  }

  static AppPreferencesCompanion deviceCompanion(UserPreferences preferences) {
    return AppPreferencesCompanion(
      id: const Value(preferencesId),
      themeMode: Value(preferences.themeMode.name),
      hasCompletedOnboarding: Value(preferences.hasCompletedOnboarding),
      activeUserId: Value(preferences.activeUserId),
      biometricUnlockEnabled: Value(preferences.biometricUnlockEnabled),
      biometricUserId: Value(preferences.biometricUserId),
    );
  }

  static UserSettingsCompanion settingsCompanion({
    required String userId,
    required UserPreferences preferences,
  }) {
    return UserSettingsCompanion(
      userId: Value(userId),
      themeMode: Value(preferences.themeMode.name),
      notificationsEnabled: Value(preferences.notificationsEnabled),
      billRemindersEnabled: Value(preferences.billRemindersEnabled),
      budgetAlertsEnabled: Value(preferences.budgetAlertsEnabled),
      goalRemindersEnabled: Value(preferences.goalRemindersEnabled),
      productUpdatesEnabled: Value(preferences.productUpdatesEnabled),
      backupDriveEmail: Value(preferences.backupDriveEmail),
      backupDriveFileId: Value(preferences.backupDriveFileId),
      lastBackupAt: Value(preferences.lastBackupAt),
      defaultCategoryId: Value(preferences.defaultCategoryId),
      lastUsedCategoryId: Value(preferences.lastUsedCategoryId),
      dashboardLayoutJson: Value(preferences.dashboardLayoutJson),
      analyticsPeriod: Value(preferences.analyticsPeriod),
      quickActionsJson: Value(preferences.quickActionsJson),
    );
  }

  static ThemeMode _themeMode(String name) {
    for (final mode in ThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return ThemeMode.dark;
  }
}
