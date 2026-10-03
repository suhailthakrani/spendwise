import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/database/app_database.dart';
import 'package:spendwise/core/database/database_seed.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertUser(String userId) async {
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: userId,
            name: 'Ada',
            email: 'ada@example.com',
          ),
        );
  }

  Future<void> insertCat({
    required String id,
    required String userId,
    required String name,
    bool custom = true,
  }) {
    return db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            userId: Value(userId),
            name: name,
            iconName: 'category',
            colorValue: 1,
            isCustom: Value(custom),
          ),
        );
  }

  test('merges Grocery/Groceries and skips duplicate Education seed', () async {
    const userId = 'user_a';
    await insertUser(userId);
    await insertCat(id: 'custom_grocery', userId: userId, name: 'Grocery');
    await insertCat(id: 'custom_education', userId: userId, name: 'Education');

    await seedCategoriesForUser(db, userId);

    final rows = await (db.select(db.categories)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final keys = rows.map((r) => r.name.toLowerCase()).toList();

    expect(keys.where((n) => n.contains('grocer')).length, 1);
    expect(keys.where((n) => n == 'education').length, 1);
  });

  test('merges near-duplicate labels and legacy bare seed ids', () async {
    const userId = 'user_b';
    await insertUser(userId);

    await insertCat(id: 'cat_light', userId: userId, name: 'Light', custom: false);
    await insertCat(
      id: '${userId}__cat_light',
      userId: userId,
      name: 'Electricity',
      custom: false,
    );
    await insertCat(id: 'custom_food', userId: userId, name: 'Food');
    await insertCat(
      id: '${userId}__cat_food_dining',
      userId: userId,
      name: 'Food & Dining',
      custom: false,
    );
    await insertCat(id: 'custom_petrol', userId: userId, name: 'Petrol');
    await insertCat(
      id: '${userId}__cat_fuel',
      userId: userId,
      name: 'Fuel',
      custom: false,
    );
    await insertCat(id: 'custom_medical', userId: userId, name: 'Medical');
    await insertCat(
      id: '${userId}__cat_health',
      userId: userId,
      name: 'Health',
      custom: false,
    );
    await insertCat(id: 'custom_misc', userId: userId, name: 'Misc');
    await insertCat(
      id: '${userId}__cat_other',
      userId: userId,
      name: 'Other',
      custom: false,
    );

    await dedupeCategoriesForUser(db, userId);

    final rows = await (db.select(db.categories)
          ..where((t) => t.userId.equals(userId)))
        .get();
    final names = rows.map((r) => r.name).toSet();

    expect(names.intersection({'Light', 'Electricity'}).length, 1);
    expect(names.intersection({'Food', 'Food & Dining'}).length, 1);
    expect(names.intersection({'Petrol', 'Fuel'}).length, 1);
    expect(names.intersection({'Medical', 'Health'}).length, 1);
    expect(names.intersection({'Misc', 'Other'}).length, 1);
    // Gas and Fuel stay distinct when both present as utilities vs vehicle.
    expect(rows.length, 5);
  });
}
