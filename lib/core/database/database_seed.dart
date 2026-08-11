import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'app_database.dart';

const _preferencesId = 1;
const _profileId = 'profile_main';

/// Bootstraps only what a new install needs to run.
///
/// Never inserts expenses, budgets, recurring items, or fake profile info.
Future<void> seedDatabase(AppDatabase db) async {
  await db.batch((batch) {
    batch.insertAll(db.categories, defaultCategories);
    batch.insert(db.appPreferences, _defaultPreferences);
    batch.insert(db.userProfiles, _defaultProfile);
  });
}

/// Adds any missing starter categories without touching existing ones.
Future<void> ensureStarterCategories(AppDatabase db) async {
  await db.batch((batch) {
    batch.insertAll(
      db.categories,
      defaultCategories,
      mode: InsertMode.insertOrIgnore,
    );
  });
}

final _defaultPreferences = AppPreferencesCompanion.insert(
  id: Value(_preferencesId),
  themeMode: ThemeMode.light.name,
  regionCode: 'US',
  currencyCode: 'USD',
);

final _defaultProfile = UserProfilesCompanion.insert(
  id: _profileId,
  name: '',
  email: '',
);

/// Everyday starter categories. Users can add more custom ones anytime.
final defaultCategories = <CategoriesCompanion>[
  CategoriesCompanion.insert(
    id: 'cat_home_rent',
    name: 'Home Rent',
    iconName: 'home',
    colorValue: const Color(0xFF0D9488).toARGB32(),
  ),
  CategoriesCompanion.insert(
    id: 'cat_internet',
    name: 'Internet',
    iconName: 'wifi',
    colorValue: const Color(0xFF3B82F6).toARGB32(),
  ),
  CategoriesCompanion.insert(
    id: 'cat_gas',
    name: 'Gas',
    iconName: 'flame',
    colorValue: const Color(0xFFF97316).toARGB32(),
  ),
  CategoriesCompanion.insert(
    id: 'cat_light',
    name: 'Light',
    iconName: 'bolt',
    colorValue: const Color(0xFFF59E0B).toARGB32(),
  ),
  CategoriesCompanion.insert(
    id: 'cat_grocery',
    name: 'Grocery',
    iconName: 'grocery',
    colorValue: const Color(0xFF10B981).toARGB32(),
  ),
  CategoriesCompanion.insert(
    id: 'cat_shopping',
    name: 'Shopping',
    iconName: 'shopping_bag',
    colorValue: const Color(0xFFEC4899).toARGB32(),
  ),
  CategoriesCompanion.insert(
    id: 'cat_fuel',
    name: 'Fuel',
    iconName: 'directions_car',
    colorValue: const Color(0xFF6366F1).toARGB32(),
  ),
  CategoriesCompanion.insert(
    id: 'cat_health',
    name: 'Health',
    iconName: 'favorite',
    colorValue: const Color(0xFFEF4444).toARGB32(),
  ),
  CategoriesCompanion.insert(
    id: 'cat_education',
    name: 'Education',
    iconName: 'school',
    colorValue: const Color(0xFF06B6D4).toARGB32(),
  ),
  CategoriesCompanion.insert(
    id: 'cat_entertainment',
    name: 'Entertainment',
    iconName: 'movie',
    colorValue: const Color(0xFF8B5CF6).toARGB32(),
  ),
  CategoriesCompanion.insert(
    id: 'cat_investment',
    name: 'Investment',
    iconName: 'savings',
    colorValue: const Color(0xFF059669).toARGB32(),
  ),
];
