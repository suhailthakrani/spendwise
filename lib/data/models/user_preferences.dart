import 'package:flutter/material.dart';

class UserPreferences {
  const UserPreferences({
    required this.themeMode,
    this.hasCompletedOnboarding = false,
    this.activeUserId,
    this.notificationsEnabled = true,
    this.billRemindersEnabled = true,
    this.budgetAlertsEnabled = true,
    this.goalRemindersEnabled = true,
    this.productUpdatesEnabled = false,
    this.backupDriveEmail,
    this.lastBackupAt,
    this.backupDriveFileId,
    this.biometricUnlockEnabled = false,
    this.biometricUserId,
  });

  final ThemeMode themeMode;
  final bool hasCompletedOnboarding;
  final String? activeUserId;
  final bool notificationsEnabled;
  final bool billRemindersEnabled;
  final bool budgetAlertsEnabled;
  final bool goalRemindersEnabled;
  final bool productUpdatesEnabled;
  final String? backupDriveEmail;
  final DateTime? lastBackupAt;
  final String? backupDriveFileId;
  final bool biometricUnlockEnabled;
  final String? biometricUserId;

  bool get isSignedIn =>
      activeUserId != null && activeUserId!.trim().isNotEmpty;

  bool get billRemindersActive =>
      notificationsEnabled && billRemindersEnabled;
  bool get budgetAlertsActive =>
      notificationsEnabled && budgetAlertsEnabled;
  bool get goalRemindersActive =>
      notificationsEnabled && goalRemindersEnabled;
  bool get productUpdatesActive =>
      notificationsEnabled && productUpdatesEnabled;

  bool get hasBackupDriveEmail =>
      backupDriveEmail != null && backupDriveEmail!.trim().isNotEmpty;

  bool get canUnlockWithBiometrics =>
      biometricUnlockEnabled &&
      biometricUserId != null &&
      biometricUserId!.trim().isNotEmpty;

  factory UserPreferences.defaults() => const UserPreferences(
        themeMode: ThemeMode.light,
      );

  UserPreferences copyWith({
    ThemeMode? themeMode,
    bool? hasCompletedOnboarding,
    String? activeUserId,
    bool clearActiveUserId = false,
    bool? notificationsEnabled,
    bool? billRemindersEnabled,
    bool? budgetAlertsEnabled,
    bool? goalRemindersEnabled,
    bool? productUpdatesEnabled,
    String? backupDriveEmail,
    bool clearBackupDriveEmail = false,
    DateTime? lastBackupAt,
    bool clearLastBackupAt = false,
    String? backupDriveFileId,
    bool clearBackupDriveFileId = false,
    bool? biometricUnlockEnabled,
    String? biometricUserId,
    bool clearBiometricUserId = false,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      activeUserId:
          clearActiveUserId ? null : (activeUserId ?? this.activeUserId),
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      billRemindersEnabled: billRemindersEnabled ?? this.billRemindersEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      goalRemindersEnabled: goalRemindersEnabled ?? this.goalRemindersEnabled,
      productUpdatesEnabled:
          productUpdatesEnabled ?? this.productUpdatesEnabled,
      backupDriveEmail: clearBackupDriveEmail
          ? null
          : (backupDriveEmail ?? this.backupDriveEmail),
      lastBackupAt:
          clearLastBackupAt ? null : (lastBackupAt ?? this.lastBackupAt),
      backupDriveFileId: clearBackupDriveFileId
          ? null
          : (backupDriveFileId ?? this.backupDriveFileId),
      biometricUnlockEnabled:
          biometricUnlockEnabled ?? this.biometricUnlockEnabled,
      biometricUserId: clearBiometricUserId
          ? null
          : (biometricUserId ?? this.biometricUserId),
    );
  }
}
