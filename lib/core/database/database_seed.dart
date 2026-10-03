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
/// skips names that already exist (incl. aliases like Grocery/Groceries),
/// merges accidental duplicates, and keeps built-in icons in sync.
Future<void> seedCategoriesForUser(AppDatabase db, String userId) async {
  final defaults = defaultCategoriesForUser(userId);
  final existing = await (db.select(db.categories)
        ..where((t) => t.userId.equals(userId)))
      .get();

  final takenKeys = <String>{
    for (final row in existing) _categoryMatchKey(row.name),
  };

  final toInsert = <CategoriesCompanion>[];
  for (final cat in defaults) {
    final key = _categoryMatchKey(cat.name.value);
    if (takenKeys.contains(key)) continue;
    takenKeys.add(key);
    toInsert.add(cat);
  }

  if (toInsert.isNotEmpty) {
    await db.batch((batch) {
      batch.insertAll(
        db.categories,
        toInsert,
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  await _syncLegacySeedNames(db, userId);
  await _syncSeedIcons(db, defaults);
  await dedupeCategoriesForUser(db, userId);
}

/// Merges categories that share the same name / known alias for [userId].
///
/// Keeps the best row (seed id preferred, then most used), moves references,
/// then deletes the extras. Safe to call repeatedly.
Future<void> dedupeCategoriesForUser(AppDatabase db, String userId) async {
  final rows = await (db.select(db.categories)
        ..where((t) => t.userId.equals(userId)))
      .get();
  if (rows.length < 2) return;

  final groups = <String, List<CategoryRow>>{};
  for (final row in rows) {
    final key = _categoryMatchKey(row.name);
    groups.putIfAbsent(key, () => []).add(row);
  }

  for (final group in groups.values) {
    if (group.length < 2) continue;
    await _mergeCategoryGroup(db, userId, group);
  }
}

Future<void> _mergeCategoryGroup(
  AppDatabase db,
  String userId,
  List<CategoryRow> group,
) async {
  final usage = <String, int>{};
  for (final row in group) {
    final count = await (db.select(db.expenses)
          ..where(
            (t) => t.userId.equals(userId) & t.categoryId.equals(row.id),
          ))
        .get();
    usage[row.id] = count.length;
  }

  group.sort((a, b) {
    final aSeed = _isSeedCategoryId(a.id, userId);
    final bSeed = _isSeedCategoryId(b.id, userId);
    if (aSeed != bSeed) return aSeed ? -1 : 1;
    final useCmp = (usage[b.id] ?? 0).compareTo(usage[a.id] ?? 0);
    if (useCmp != 0) return useCmp;
    return a.id.compareTo(b.id);
  });

  final keep = group.first;
  final drop = group.skip(1).toList();
  final canonical = _canonicalNameFor(keep.name);

  if (keep.name != canonical) {
    await (db.update(db.categories)..where((t) => t.id.equals(keep.id))).write(
      CategoriesCompanion(name: Value(canonical)),
    );
  }

  for (final extra in drop) {
    await _repointCategoryRefs(
      db,
      userId: userId,
      fromId: extra.id,
      toId: keep.id,
    );
    await (db.delete(db.categories)..where((t) => t.id.equals(extra.id))).go();
  }
}

Future<void> _repointCategoryRefs(
  AppDatabase db, {
  required String userId,
  required String fromId,
  required String toId,
}) async {
  await (db.update(db.expenses)
        ..where((t) => t.userId.equals(userId) & t.categoryId.equals(fromId)))
      .write(ExpensesCompanion(categoryId: Value(toId)));

  await (db.update(db.budgets)
        ..where((t) => t.userId.equals(userId) & t.categoryId.equals(fromId)))
      .write(BudgetsCompanion(categoryId: Value(toId)));

  await (db.update(db.recurringExpenses)
        ..where((t) => t.userId.equals(userId) & t.categoryId.equals(fromId)))
      .write(RecurringExpensesCompanion(categoryId: Value(toId)));

  await (db.update(db.transactionTemplates)
        ..where((t) => t.userId.equals(userId) & t.categoryId.equals(fromId)))
      .write(TransactionTemplatesCompanion(categoryId: Value(toId)));

  await (db.update(db.envelopes)
        ..where((t) => t.userId.equals(userId) & t.categoryId.equals(fromId)))
      .write(EnvelopesCompanion(categoryId: Value(toId)));

  // Settings may point at the removed category as a default.
  await (db.update(db.userSettings)
        ..where(
          (t) => t.userId.equals(userId) & t.defaultCategoryId.equals(fromId),
        ))
      .write(UserSettingsCompanion(defaultCategoryId: Value(toId)));
  await (db.update(db.userSettings)
        ..where(
          (t) =>
              t.userId.equals(userId) & t.lastUsedCategoryId.equals(fromId),
        ))
      .write(UserSettingsCompanion(lastUsedCategoryId: Value(toId)));
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
  Iterable<CategoriesCompanion> defaults,
) async {
  for (final cat in defaults) {
    final id = cat.id.value;
    final icon = cat.iconName.value;
    await (db.update(db.categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(iconName: Value(icon)),
    );
  }
}

/// Public helper so create/edit flows can block near-duplicate names.
String categoryMatchKey(String name) => _categoryMatchKey(name);

/// Normalized key so near-duplicate labels collide (Grocery/Groceries, etc.).
String _categoryMatchKey(String name) {
  var key = name.trim().toLowerCase();
  key = key.replaceAll('&', ' and ');
  key = key.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  key = key.replaceAll(RegExp(r'\s+'), ' ').trim();

  String? aliasOf(String value) {
    const aliases = <String, String>{
      // Food
      'grocery': 'groceries',
      'groceries': 'groceries',
      'food': 'food dining',
      'food and dining': 'food dining',
      'food dining': 'food dining',
      'dining': 'food dining',
      'restaurant': 'food dining',
      'eating out': 'food dining',
      // Utilities / home
      'light': 'electricity',
      'lights': 'electricity',
      'electric': 'electricity',
      'electricity': 'electricity',
      'power': 'electricity',
      'home rent': 'home rent',
      'rent': 'home rent',
      'house rent': 'home rent',
      'homerent': 'home rent',
      'internet': 'internet',
      'wifi': 'internet',
      'broadband': 'internet',
      'water': 'water',
      'gas': 'gas',
      'cooking gas': 'gas',
      'utility gas': 'gas',
      // Transport
      'fuel': 'fuel',
      'petrol': 'fuel',
      'diesel': 'fuel',
      'gasoline': 'fuel',
      'cng': 'fuel',
      'transport': 'transport',
      'transportation': 'transport',
      'commute': 'transport',
      'cab': 'transport',
      'taxi': 'transport',
      'uber': 'transport',
      'vehicle': 'vehicle maintenance',
      'vehicle maintenance': 'vehicle maintenance',
      'car maintenance': 'vehicle maintenance',
      'car repair': 'vehicle maintenance',
      // Shopping / lifestyle
      'shopping': 'shopping',
      'shop': 'shopping',
      'cloth': 'clothing',
      'clothe': 'clothing',
      'clothing': 'clothing',
      'clothes': 'clothing',
      'apparel': 'clothing',
      'health': 'health',
      'healthcare': 'health',
      'medical': 'health',
      'medicine': 'health',
      'medicines': 'health',
      'hospital': 'health',
      'personal care': 'personal care',
      'personalcare': 'personal care',
      'self care': 'personal care',
      'education': 'education',
      'school': 'education',
      'study': 'education',
      'tuition': 'education',
      'fees': 'education',
      'entertainment': 'entertainment',
      'movie': 'entertainment',
      'movies': 'entertainment',
      'fun': 'entertainment',
      'subscription': 'subscriptions',
      'subscriptions': 'subscriptions',
      'ott': 'subscriptions',
      'netflix': 'subscriptions',
      'travel': 'travel',
      'trip': 'travel',
      'trips': 'travel',
      'holiday': 'travel',
      'vacation': 'travel',
      'family': 'family',
      'gift': 'gifts',
      'gifts': 'gifts',
      'charity': 'charity',
      'donation': 'charity',
      'donations': 'charity',
      'zakat': 'charity',
      'insurance': 'insurance',
      'investment': 'investment',
      'invest': 'investment',
      'investments': 'investment',
      'saving': 'savings',
      'savings': 'savings',
      'home maintenance': 'home maintenance',
      'repair': 'home maintenance',
      'repairs': 'home maintenance',
      'pet': 'pets',
      'pets': 'pets',
      'work': 'work business',
      'work and business': 'work business',
      'work business': 'work business',
      'business': 'work business',
      'office': 'work business',
      'tax': 'taxes',
      'taxes': 'taxes',
      'other': 'other',
      'misc': 'other',
      'miscellaneous': 'other',
      'general': 'other',
      'mobile': 'mobile',
      'phone': 'mobile',
      'cellphone': 'mobile',
      'income': 'income',
      'salary': 'income',
    };
    final compact = value.replaceAll(' ', '');
    return aliases[value] ?? aliases[compact];
  }

  final direct = aliasOf(key);
  if (direct != null) return direct;

  // Collapse simple plurals, then alias again.
  var singular = key;
  if (singular.length > 3 && singular.endsWith('ies')) {
    singular = '${singular.substring(0, singular.length - 3)}y';
  } else if (singular.length > 3 &&
      singular.endsWith('s') &&
      !singular.endsWith('ss') &&
      singular != 'gas' &&
      !singular.endsWith(' gas')) {
    singular = singular.substring(0, singular.length - 1);
  }
  return aliasOf(singular) ?? singular;
}

String _canonicalNameFor(String name) {
  final key = _categoryMatchKey(name);
  const canonical = <String, String>{
    'groceries': 'Groceries',
    'electricity': 'Electricity',
    'food dining': 'Food & Dining',
    'personal care': 'Personal Care',
    'home rent': 'Home Rent',
    'internet': 'Internet',
    'gas': 'Gas',
    'fuel': 'Fuel',
    'transport': 'Transport',
    'vehicle maintenance': 'Vehicle Maintenance',
    'shopping': 'Shopping',
    'clothing': 'Clothing',
    'health': 'Health',
    'education': 'Education',
    'entertainment': 'Entertainment',
    'subscriptions': 'Subscriptions',
    'travel': 'Travel',
    'family': 'Family',
    'gifts': 'Gifts',
    'charity': 'Charity',
    'insurance': 'Insurance',
    'investment': 'Investment',
    'savings': 'Savings',
    'home maintenance': 'Home Maintenance',
    'pets': 'Pets',
    'work business': 'Work & Business',
    'taxes': 'Taxes',
    'other': 'Other',
    'mobile': 'Mobile',
    'water': 'Water',
  };
  if (canonical.containsKey(key)) return canonical[key]!;
  return name.trim();
}

bool _isSeedCategoryId(String id, String userId) {
  if (id.startsWith('${userId}__cat_')) return true;
  // Legacy bare seed keys (`cat_grocery`). UUID customs look like `cat_<uuid>`.
  return id.startsWith('cat_') && !id.contains('-');
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
