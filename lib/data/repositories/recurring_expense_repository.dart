import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../mappers/recurring_expense_mapper.dart';
import '../models/recurring_expense.dart';

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

  Future<void> create(RecurringExpense expense) async {
    await _db.into(_db.recurringExpenses).insert(
          RecurringExpenseMapper.toCompanion(expense, userId: _userId),
        );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.recurringExpenses)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .go();
  }
}
