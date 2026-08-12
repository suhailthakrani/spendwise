import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'app_database.dart';

const preferencesId = 1;

/// Bootstraps only device preferences. Profiles and categories are created
/// when a user signs up.
Future<void> seedDatabase(AppDatabase db) async {
  await db.into(db.appPreferences).insert(_defaultPreferences);
}

/// Starter categories for a specific user (unique ids per account).
Future<void> seedCategoriesForUser(AppDatabase db, String userId) async {
  final existing = await (db.select(db.categories)
        ..where((t) => t.userId.equals(userId)))
      .get();
  if (existing.isNotEmpty) return;

  await db.batch((batch) {
    batch.insertAll(
      db.categories,
      defaultCategoriesForUser(userId),
      mode: InsertMode.insertOrIgnore,
    );
  });
}

final _defaultPreferences = AppPreferencesCompanion.insert(
  id: Value(preferencesId),
  themeMode: ThemeMode.light.name,
  hasCompletedOnboarding: const Value(false),
);

List<CategoriesCompanion> defaultCategoriesForUser(String userId) {
  String id(String key) => '${userId}__$key';

  return [
    CategoriesCompanion.insert(
      id: id('cat_home_rent'),
      userId: Value(userId),
      name: 'Home Rent',
      iconName: 'home',
      colorValue: const Color(0xFF0D9488).toARGB32(),
    ),
    CategoriesCompanion.insert(
      id: id('cat_internet'),
      userId: Value(userId),
      name: 'Internet',
      iconName: 'wifi',
      colorValue: const Color(0xFF3B82F6).toARGB32(),
    ),
    CategoriesCompanion.insert(
      id: id('cat_gas'),
      userId: Value(userId),
      name: 'Gas',
      iconName: 'flame',
      colorValue: const Color(0xFFF97316).toARGB32(),
    ),
    CategoriesCompanion.insert(
      id: id('cat_light'),
      userId: Value(userId),
      name: 'Light',
      iconName: 'bolt',
      colorValue: const Color(0xFFF59E0B).toARGB32(),
    ),
    CategoriesCompanion.insert(
      id: id('cat_water'),
      userId: Value(userId),
      name: 'Water',
      iconName: 'water_drop',
      colorValue: const Color(0xFF0EA5E9).toARGB32(),
    ),
    CategoriesCompanion.insert(
      id: id('cat_grocery'),
      userId: Value(userId),
      name: 'Grocery',
      iconName: 'grocery',
      colorValue: const Color(0xFF10B981).toARGB32(),
    ),
    CategoriesCompanion.insert(
      id: id('cat_shopping'),
      userId: Value(userId),
      name: 'Shopping',
      iconName: 'shopping_bag',
      colorValue: const Color(0xFFEC4899).toARGB32(),
    ),
    CategoriesCompanion.insert(
      id: id('cat_fuel'),
      userId: Value(userId),
      name: 'Fuel',
      iconName: 'directions_car',
      colorValue: const Color(0xFF6366F1).toARGB32(),
    ),
    CategoriesCompanion.insert(
      id: id('cat_health'),
      userId: Value(userId),
      name: 'Health',
      iconName: 'favorite',
      colorValue: const Color(0xFFEF4444).toARGB32(),
    ),
    CategoriesCompanion.insert(
      id: id('cat_education'),
      userId: Value(userId),
      name: 'Education',
      iconName: 'school',
      colorValue: const Color(0xFF06B6D4).toARGB32(),
    ),
    CategoriesCompanion.insert(
      id: id('cat_entertainment'),
      userId: Value(userId),
      name: 'Entertainment',
      iconName: 'movie',
      colorValue: const Color(0xFF8B5CF6).toARGB32(),
    ),
    CategoriesCompanion.insert(
      id: id('cat_investment'),
      userId: Value(userId),
      name: 'Investment',
      iconName: 'savings',
      colorValue: const Color(0xFF059669).toARGB32(),
    ),
  ];
}
