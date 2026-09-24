import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../mappers/recurring_expense_mapper.dart';
import '../models/expense.dart';
import '../models/ledger_entry_type.dart';
import '../models/recurring_expense.dart';
import 'expense_repository.dart';

class RecurringExpenseRepository {
  RecurringExpenseRepository(this._db, this._userId);

  final AppDatabase _db;
  final String _userId;

  Stream<List<RecurringExpense>> watchAll() {
    return (_db.select(_db.recurringExpenses)
          ..where((t) => t.userId.equals(_userId))
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .watch()
        .map((rows) => rows.map(RecurringExpenseMapper.fromRow).toList());
  }

  /// Bills marked for auto-post whose due date is today or earlier.
  Stream<List<RecurringExpense>> watchAutoPostQueue() {
    final endOfToday = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      23,
      59,
      59,
    );
    return (_db.select(_db.recurringExpenses)
          ..where(
            (t) =>
                t.userId.equals(_userId) &
                t.autoPost.equals(true) &
                t.nextDueDate.isSmallerOrEqualValue(endOfToday),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .watch()
        .map((rows) => rows.map(RecurringExpenseMapper.fromRow).toList());
  }

  Future<void> create(RecurringExpense expense) async {
    await _db.into(_db.recurringExpenses).insert(
          RecurringExpenseMapper.toCompanion(expense, userId: _userId),
        );
  }

  Future<void> update(RecurringExpense expense) async {
    await (_db.update(_db.recurringExpenses)
          ..where((t) => t.id.equals(expense.id) & t.userId.equals(_userId)))
        .write(
      RecurringExpensesCompanion(
        title: Value(expense.title),
        amount: Value(expense.amount),
        categoryId: Value(expense.categoryId),
        frequency: Value(expense.frequency.name),
        nextDueDate: Value(expense.nextDueDate),
        paymentMethod: Value(expense.paymentMethod.name),
        entryType: Value(expense.entryType.name),
        autoPost: Value(expense.autoPost),
      ),
    );
  }

  /// Posts a ledger row for [bill] and advances [RecurringExpense.nextDueDate].
  Future<Expense> postNow(
    RecurringExpense bill, {
    required ExpenseRepository expenses,
    required String Function() newExpenseId,
  }) async {
    final now = DateTime.now();
    final entryType = bill.entryType == LedgerEntryType.income
        ? LedgerEntryType.income
        : LedgerEntryType.expense;

    final expense = Expense(
      id: newExpenseId(),
      amount: bill.amount,
      categoryId: bill.categoryId,
      note: bill.title,
      date: now,
      paymentMethod: bill.paymentMethod,
      type: entryType,
      isRecurring: true,
    );
    await expenses.create(expense);

    final nextDue = _advanceDue(bill.nextDueDate, bill.frequency);
    await (_db.update(_db.recurringExpenses)
          ..where((t) => t.id.equals(bill.id) & t.userId.equals(_userId)))
        .write(RecurringExpensesCompanion(nextDueDate: Value(nextDue)));

    return expense;
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.recurringExpenses)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .go();
  }

  static DateTime _advanceDue(DateTime from, RecurrenceFrequency frequency) {
    return switch (frequency) {
      RecurrenceFrequency.weekly => from.add(const Duration(days: 7)),
      RecurrenceFrequency.monthly => DateTime(
          from.year,
          from.month + 1,
          from.day,
          from.hour,
          from.minute,
          from.second,
          from.millisecond,
          from.microsecond,
        ),
      RecurrenceFrequency.yearly => DateTime(
          from.year + 1,
          from.month,
          from.day,
          from.hour,
          from.minute,
          from.second,
          from.millisecond,
          from.microsecond,
        ),
    };
  }
}
