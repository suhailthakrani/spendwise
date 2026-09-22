import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/expense.dart';
import '../models/ledger_entry_type.dart';
import '../models/payment_method.dart';

abstract final class ExpenseMapper {
  static Expense fromRow(ExpenseRow row) {
    return Expense(
      id: row.id,
      amount: row.amount,
      categoryId: row.categoryId,
      note: row.note,
      date: row.date,
      paymentMethod: PaymentMethod.values.byName(row.paymentMethod),
      accountId: row.accountId,
      type: LedgerEntryType.fromDb(row.type),
      toAccountId: row.toAccountId,
      isRecurring: row.isRecurring,
    );
  }

  static ExpensesCompanion toCompanion(
    Expense expense, {
    required String userId,
  }) {
    return ExpensesCompanion(
      id: Value(expense.id),
      userId: Value(userId),
      amount: Value(expense.amount),
      categoryId: Value(expense.categoryId),
      note: Value(expense.note),
      date: Value(expense.date),
      paymentMethod: Value(expense.paymentMethod.name),
      isRecurring: Value(expense.isRecurring),
      type: Value(expense.type.name),
      accountId: Value(expense.accountId),
      toAccountId: Value(expense.toAccountId),
    );
  }
}
