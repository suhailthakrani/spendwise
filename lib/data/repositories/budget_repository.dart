import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../mappers/budget_mapper.dart';
import '../models/budget.dart';
import 'expense_repository.dart';

class BudgetRepository {
  BudgetRepository(this._db, this._expenses, this._userId);

  final AppDatabase _db;
  final ExpenseRepository _expenses;
  final String _userId;

  /// Emits whenever budgets **or** expenses change so [Budget.spent] stays fresh.
  Stream<List<Budget>> watchAll() {
    return Stream.multi((controller) {
      List<BudgetRow>? latestRows;
      var emitting = false;
      var queued = false;

      Future<void> emit() async {
        if (latestRows == null) return;
        if (emitting) {
          queued = true;
          return;
        }
        emitting = true;
        try {
          do {
            queued = false;
            final mapped = await _mapBudgets(latestRows!);
            if (!controller.isClosed) controller.add(mapped);
          } while (queued);
        } catch (error, stackTrace) {
          if (!controller.isClosed) {
            controller.addError(error, stackTrace);
          }
        } finally {
          emitting = false;
        }
      }

      final budgetSub = (_db.select(_db.budgets)
            ..where((t) => t.userId.equals(_userId)))
          .watch()
          .listen(
        (rows) {
          latestRows = rows;
          emit();
        },
        onError: controller.addError,
      );

      final expenseSub = (_db.select(_db.expenses)
            ..where((t) => t.userId.equals(_userId)))
          .watch()
          .listen(
        (_) => emit(),
        onError: controller.addError,
      );

      controller.onCancel = () async {
        await budgetSub.cancel();
        await expenseSub.cancel();
      };
    });
  }

  Future<Budget?> getById(String id) async {
    final row = await (_db.select(_db.budgets)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .getSingleOrNull();
    if (row == null) return null;
    final spent = await _spentForBudget(row);
    return BudgetMapper.fromRow(row, spent: spent);
  }

  Future<void> create({
    required String id,
    required String name,
    required double limit,
    required int year,
    required int month,
    String? categoryId,
    bool isMonthly = true,
  }) async {
    await _db.into(_db.budgets).insert(
          BudgetMapper.toCompanion(
            id: id,
            userId: _userId,
            name: name,
            limit: limit,
            year: year,
            month: month,
            categoryId: categoryId,
            isMonthly: isMonthly,
          ),
        );
  }

  Future<void> update({
    required String id,
    required String name,
    required double limit,
    required int year,
    required int month,
    String? categoryId,
    bool isMonthly = true,
  }) async {
    await (_db.update(_db.budgets)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .write(
      BudgetsCompanion(
        name: Value(name),
        limitAmount: Value(limit),
        categoryId: Value(categoryId),
        isMonthly: Value(isMonthly),
        year: Value(year),
        month: Value(month),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.budgets)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .go();
  }

  Future<List<Budget>> _mapBudgets(List<BudgetRow> rows) async {
    final budgets = <Budget>[];
    for (final row in rows) {
      final spent = await _spentForBudget(row);
      budgets.add(BudgetMapper.fromRow(row, spent: spent));
    }
    budgets.sort((a, b) {
      final byPeriod = DateTime(b.year, b.month).compareTo(DateTime(a.year, a.month));
      if (byPeriod != 0) return byPeriod;
      if (a.categoryId == null) return -1;
      if (b.categoryId == null) return 1;
      return a.name.compareTo(b.name);
    });
    return budgets;
  }

  Future<double> _spentForBudget(BudgetRow row) {
    return _expenses.sumForMonth(
      categoryId: row.categoryId,
      month: DateTime(row.year, row.month),
    );
  }
}
