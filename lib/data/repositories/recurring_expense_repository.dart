import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../mappers/recurring_expense_mapper.dart';
import '../models/recurring_expense.dart';

class RecurringExpenseRepository {
  RecurringExpenseRepository(this._db);

  final AppDatabase _db;

  Stream<List<RecurringExpense>> watchAll() {
    return (_db.select(_db.recurringExpenses)
          ..orderBy([(t) => OrderingTerm.asc(t.nextDueDate)]))
        .watch()
        .map((rows) => rows.map(RecurringExpenseMapper.fromRow).toList());
  }

  Future<void> create(RecurringExpense expense) async {
    await _db
        .into(_db.recurringExpenses)
        .insert(RecurringExpenseMapper.toCompanion(expense));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.recurringExpenses)..where((t) => t.id.equals(id)))
        .go();
  }
}
