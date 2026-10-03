import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'app_database.dart';

const preferencesId = 1;

/// Bootstraps only device preferences. Profiles and categories are created
/// when a user signs up.
Future<void> seedDatabase(AppDatabase db) async {
  await db.into(db.appPreferences).insert(_defaultPreferences);
}

/// Gives an account its own settings row. Safe to call repeatedly — an existing
/// row is never overwritten, so a user's choices survive later sign-ins.
Future<void> seedSettingsForUser(AppDatabase db, String userId) async {
  await db.into(db.userSettings).insert(
        UserSettingsCompanion.insert(userId: userId),
        mode: InsertMode.insertOrIgnore,
      );
}

/// Ensures starter categories exist for a user. Safe to call repeatedly —
/// missing defaults are inserted; built-in seed icons are kept in sync.
/// Legacy seed names are renamed only when still unchanged.
Future<void> seedCategoriesForUser(AppDatabase db, String userId) async {
  final defaults = defaultCategoriesForUser(userId);
  await db.batch((batch) {
    batch.insertAll(
      db.categories,
      defaults,
      mode: InsertMode.insertOrIgnore,
    );
  });
  await _syncLegacySeedNames(db, userId);
  await _syncSeedIcons(db, defaults);
}

/// Renames built-in seed rows only when the user has not already renamed them.
Future<void> _syncLegacySeedNames(AppDatabase db, String userId) async {
  const renames = <String, (String, String)>{
    'cat_light': ('Light', 'Electricity'),
    'cat_grocery': ('Grocery', 'Groceries'),
  };

  for (final entry in renames.entries) {
    final id = '${userId}__${entry.key}';
    final (from, to) = entry.value;
    await (db.update(db.categories)
          ..where((t) => t.id.equals(id) & t.name.equals(from)))
        .write(CategoriesCompanion(name: Value(to)));
  }
}

/// Keeps built-in seed category icons aligned with the current defaults.
Future<void> _syncSeedIcons(
  AppDatabase db,
  List<CategoriesCompanion> defaults,
) async {
  for (final cat in defaults) {
    final id = cat.id.value;
    final icon = cat.iconName.value;
    await (db.update(db.categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(iconName: Value(icon)),
    );
  }
}

final _defaultPreferences = AppPreferencesCompanion.insert(
  id: Value(preferencesId),
  themeMode: ThemeMode.dark.name,
  hasCompletedOnboarding: const Value(false),
);

List<CategoriesCompanion> defaultCategoriesForUser(String userId) {
  String id(String key) => '${userId}__$key';

  CategoriesCompanion cat(
    String key,
    String name,
    String icon,
    int color,
  ) {
    return CategoriesCompanion.insert(
      id: id(key),
      userId: Value(userId),
      name: name,
      iconName: icon,
      colorValue: Color(color).toARGB32(),
    );
  }

  return [
    cat('cat_home_rent', 'Home Rent', 'home', 0xFF0D9488),
    cat('cat_light', 'Electricity', 'bolt', 0xFFF59E0B),
    cat('cat_gas', 'Gas', 'flame', 0xFFF97316),
    cat('cat_water', 'Water', 'water_drop', 0xFF0EA5E9),
    cat('cat_internet', 'Internet', 'wifi', 0xFF3B82F6),
    cat('cat_mobile', 'Mobile', 'phone', 0xFF6366F1),
    cat('cat_grocery', 'Groceries', 'grocery', 0xFF10B981),
    cat('cat_food_dining', 'Food & Dining', 'restaurant', 0xFFF43F5E),
    cat('cat_fuel', 'Fuel', 'fuel', 0xFF6366F1),
    cat('cat_transport', 'Transport', 'transport', 0xFF8B5CF6),
    cat('cat_shopping', 'Shopping', 'shopping_bag', 0xFFEC4899),
    cat('cat_clothing', 'Clothing', 'clothing', 0xFFD946EF),
    cat('cat_health', 'Health', 'favorite', 0xFFEF4444),
    cat('cat_personal_care', 'Personal Care', 'personal_care', 0xFFFB7185),
    cat('cat_education', 'Education', 'school', 0xFF06B6D4),
    cat('cat_entertainment', 'Entertainment', 'movie', 0xFF8B5CF6),
    cat('cat_subscriptions', 'Subscriptions', 'repeat', 0xFF64748B),
    cat('cat_travel', 'Travel', 'globe', 0xFF14B8A6),
    cat('cat_family', 'Family', 'family', 0xFFA855F7),
    cat('cat_gifts', 'Gifts', 'gift', 0xFFE11D48),
    cat('cat_charity', 'Charity', 'charity', 0xFFDB2777),
    cat('cat_insurance', 'Insurance', 'shield', 0xFF475569),
    cat('cat_investment', 'Investment', 'savings', 0xFF059669),
    cat('cat_savings', 'Savings', 'wallet', 0xFF0F766E),
    cat('cat_home_maintenance', 'Home Maintenance', 'tools', 0xFF78716C),
    cat('cat_vehicle_maintenance', 'Vehicle Maintenance', 'wrench', 0xFF4F46E5),
    cat('cat_pets', 'Pets', 'paw', 0xFFEA580C),
    cat('cat_work_business', 'Work & Business', 'briefcase', 0xFF2563EB),
    cat('cat_taxes', 'Taxes', 'currency', 0xFFB45309),
    cat('cat_other', 'Other', 'category', 0xFF6B7280),
  ];
}
