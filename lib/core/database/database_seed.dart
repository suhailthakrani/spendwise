import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';

const _preferencesId = 1;
const _uuid = Uuid();

/// Inserts default rows on first database creation.
Future<void> seedDatabase(AppDatabase db) async {
  await db.batch((batch) {
    batch.insertAll(db.categories, _defaultCategories);
    batch.insert(db.appPreferences, _defaultPreferences);
    batch.insert(db.userProfiles, _defaultProfile);
  });
}

final _defaultPreferences = AppPreferencesCompanion.insert(
  id: Value(_preferencesId),
  themeMode: ThemeMode.light.name,
  regionCode: 'US',
  currencyCode: 'USD',
);

final _defaultProfile = UserProfilesCompanion.insert(
  id: _uuid.v4(),
  name: 'Alex Morgan',
  email: 'alex.morgan@evenlogix.com',
  memberSince: Value(DateTime(2025, 3, 15)),
);

final _defaultCategories = <CategoriesCompanion>[
  CategoriesCompanion.insert(
    id: 'cat_food',
    name: 'Food',
    iconName: 'restaurant',
    colorValue: const Color(0xFF10B981).toARGB32(),
    budgetLimit: const Value(500),
  ),
  CategoriesCompanion.insert(
    id: 'cat_transport',
    name: 'Transport',
    iconName: 'directions_car',
    colorValue: const Color(0xFF3B82F6).toARGB32(),
    budgetLimit: const Value(300),
  ),
  CategoriesCompanion.insert(
    id: 'cat_shopping',
    name: 'Shopping',
    iconName: 'shopping_bag',
    colorValue: const Color(0xFFEC4899).toARGB32(),
    budgetLimit: const Value(400),
  ),
  CategoriesCompanion.insert(
    id: 'cat_bills',
    name: 'Bills',
    iconName: 'receipt_long',
    colorValue: const Color(0xFFF59E0B).toARGB32(),
    budgetLimit: const Value(600),
  ),
  CategoriesCompanion.insert(
    id: 'cat_entertainment',
    name: 'Entertainment',
    iconName: 'movie',
    colorValue: const Color(0xFF8B5CF6).toARGB32(),
    budgetLimit: const Value(200),
  ),
  CategoriesCompanion.insert(
    id: 'cat_health',
    name: 'Health',
    iconName: 'favorite',
    colorValue: const Color(0xFFEF4444).toARGB32(),
    isCustom: const Value(true),
    budgetLimit: const Value(150),
  ),
  CategoriesCompanion.insert(
    id: 'cat_education',
    name: 'Education',
    iconName: 'school',
    colorValue: const Color(0xFF06B6D4).toARGB32(),
    isCustom: const Value(true),
  ),
];
