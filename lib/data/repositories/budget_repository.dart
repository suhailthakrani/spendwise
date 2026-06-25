import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../mappers/budget_mapper.dart';
import '../models/budget.dart';
import 'expense_repository.dart';

class BudgetRepository {
  BudgetRepository(this._db, this._expenses);

  final AppDatabase _db;
  final ExpenseRepository _expenses;

  Stream<List<Budget>> watchAll() {
    return _db.select(_db.budgets).watch().asyncMap(_mapBudgets);
  }

  Future<Budget?> getById(String id) async {
    final row = await (_db.select(_db.budgets)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    final spent = await _spentForBudget(row);
    return BudgetMapper.fromRow(row, spent: spent);
  }

  Future<void> create({
    required String id,
    required String name,
    required double limit,
    String? categoryId,
    bool isMonthly = true,
  }) async {
    await _db.into(_db.budgets).insert(
          BudgetMapper.toCompanion(
            id: id,
            name: name,
            limit: limit,
            categoryId: categoryId,
            isMonthly: isMonthly,
          ),
        );
  }

  Future<void> update({
    required String id,
    required String name,
    required double limit,
    String? categoryId,
    bool isMonthly = true,
  }) async {
    await (_db.update(_db.budgets)..where((t) => t.id.equals(id))).write(
          BudgetsCompanion(
            name: Value(name),
            limitAmount: Value(limit),
            categoryId: Value(categoryId),
            isMonthly: Value(isMonthly),
          ),
        );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.budgets)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Budget>> _mapBudgets(List<BudgetRow> rows) async {
    final now = DateTime.now();
    final budgets = <Budget>[];
    for (final row in rows) {
      final spent = await _spentForBudget(row, month: now);
      budgets.add(BudgetMapper.fromRow(row, spent: spent));
    }
    budgets.sort((a, b) {
      if (a.categoryId == null) return -1;
      if (b.categoryId == null) return 1;
      return a.name.compareTo(b.name);
    });
    return budgets;
  }

  Future<double> _spentForBudget(BudgetRow row, {DateTime? month}) async {
    final reference = month ?? DateTime.now();
    return _expenses.sumForMonth(
      categoryId: row.categoryId,
      month: reference,
    );
  }
}
