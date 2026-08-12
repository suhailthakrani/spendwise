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
    );
  }

  static AppPreferencesCompanion toCompanion(UserPreferences preferences) {
    return AppPreferencesCompanion(
      id: const Value(preferencesId),
      themeMode: Value(preferences.themeMode.name),
      hasCompletedOnboarding: Value(preferences.hasCompletedOnboarding),
      activeUserId: Value(preferences.activeUserId),
    );
  }
}
