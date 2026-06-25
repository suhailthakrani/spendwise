import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../mappers/expense_mapper.dart';
import '../models/expense.dart';
import '../models/expense_sort.dart';

class ExpenseRepository {
  ExpenseRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Expense>> watchAll() {
    return (_db.select(_db.expenses)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch()
        .map((rows) => rows.map(ExpenseMapper.fromRow).toList());
  }

  Stream<Expense?> watchById(String id) {
    return (_db.select(_db.expenses)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : ExpenseMapper.fromRow(row));
  }

  Stream<List<Expense>> watchByCategory(String categoryId) {
    return (_db.select(_db.expenses)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch()
        .map((rows) => rows.map(ExpenseMapper.fromRow).toList());
  }

  Future<Expense?> getById(String id) async {
    final row = await (_db.select(_db.expenses)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : ExpenseMapper.fromRow(row);
  }

  Future<List<Expense>> search({
    String query = '',
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    ExpenseSortBy sortBy = ExpenseSortBy.dateDesc,
    required double Function(double) toDisplayAmount,
  }) async {
    var queryBuilder = _db.select(_db.expenses);

    if (categoryId != null) {
      queryBuilder = queryBuilder..where((t) => t.categoryId.equals(categoryId));
    }
    if (startDate != null) {
      queryBuilder = queryBuilder..where((t) => t.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      queryBuilder = queryBuilder..where((t) => t.date.isSmallerOrEqualValue(end));
    }

    var results = await queryBuilder.get();
    var expenses = results.map(ExpenseMapper.fromRow).toList();

    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      expenses = expenses
          .where((e) => e.note.toLowerCase().contains(lower))
          .toList();
    }

    switch (sortBy) {
      case ExpenseSortBy.dateDesc:
        expenses.sort((a, b) => b.date.compareTo(a.date));
      case ExpenseSortBy.dateAsc:
        expenses.sort((a, b) => a.date.compareTo(b.date));
      case ExpenseSortBy.amountDesc:
        expenses.sort(
          (a, b) =>
              toDisplayAmount(b.amount).compareTo(toDisplayAmount(a.amount)),
        );
      case ExpenseSortBy.amountAsc:
        expenses.sort(
          (a, b) =>
              toDisplayAmount(a.amount).compareTo(toDisplayAmount(b.amount)),
        );
    }

    return expenses;
  }

  Future<double> sumForMonth({
    String? categoryId,
    required DateTime month,
  }) async {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    var query = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.amount.sum()])
      ..where(
        _db.expenses.date.isBetweenValues(monthStart, monthEnd),
      );

    if (categoryId != null) {
      query = query..where(_db.expenses.categoryId.equals(categoryId));
    }

    final row = await query.getSingle();
    return row.read(_db.expenses.amount.sum()) ?? 0;
  }

  Future<double> sumForDay(DateTime day, {String? categoryId}) async {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);

    var query = _db.selectOnly(_db.expenses)
      ..addColumns([_db.expenses.amount.sum()])
      ..where(_db.expenses.date.isBetweenValues(dayStart, dayEnd));

    if (categoryId != null) {
      query = query..where(_db.expenses.categoryId.equals(categoryId));
    }

    final row = await query.getSingle();
    return row.read(_db.expenses.amount.sum()) ?? 0;
  }

  Future<void> create(Expense expense) async {
    await _db.into(_db.expenses).insert(ExpenseMapper.toCompanion(expense));
  }

  Future<void> update(Expense expense) async {
    await (_db.update(_db.expenses)..where((t) => t.id.equals(expense.id))).write(
          ExpensesCompanion(
            amount: Value(expense.amount),
            categoryId: Value(expense.categoryId),
            note: Value(expense.note),
            date: Value(expense.date),
            paymentMethod: Value(expense.paymentMethod.name),
            isRecurring: Value(expense.isRecurring),
          ),
        );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.expenses)..where((t) => t.id.equals(id))).go();
  }

  String newId() => _uuid.v4();
}
