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
  });

  final ThemeMode themeMode;
  final bool hasCompletedOnboarding;
  final String? activeUserId;
  final bool notificationsEnabled;
  final bool billRemindersEnabled;
  final bool budgetAlertsEnabled;
  final bool goalRemindersEnabled;
  final bool productUpdatesEnabled;

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
    );
  }
}
