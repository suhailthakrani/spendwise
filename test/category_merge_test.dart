import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/database/app_database.dart';
import 'package:spendwise/data/models/expense.dart';
import 'package:spendwise/data/models/ledger_entry_type.dart';
import 'package:spendwise/data/models/payment_method.dart';
import 'package:spendwise/data/repositories/category_repository.dart';
import 'package:spendwise/data/repositories/expense_repository.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  test('mergeInto moves expenses and deletes source safely', () async {
    const userId = 'user_merge';
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: userId,
            name: 'Ada',
            email: 'ada@example.com',
          ),
        );
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'from',
            userId: const Value(userId),
            name: 'Gym',
            iconName: 'category',
            colorValue: 1,
            isCustom: const Value(true),
          ),
        );
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: 'into',
            userId: const Value(userId),
            name: 'Health',
            iconName: 'favorite',
            colorValue: 2,
          ),
        );

    final expenses = ExpenseRepository(db, userId);
    await expenses.create(
      Expense(
        id: 'e1',
        amount: 10,
        categoryId: 'from',
        note: 'Day pass',
        date: DateTime(2026, 1, 1),
        paymentMethod: PaymentMethod.cash,
        type: LedgerEntryType.expense,
      ),
    );

    final categories = CategoryRepository(db, userId);
    await categories.mergeInto(fromId: 'from', intoId: 'into');

    final remaining = await (db.select(db.categories)
          ..where((t) => t.userId.equals(userId)))
        .get();
    expect(remaining.map((r) => r.id), ['into']);

    final moved = await expenses.watchByCategory('into').first;
    expect(moved.length, 1);
    expect(moved.first.id, 'e1');
  });
}
