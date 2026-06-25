import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/expense.dart';
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
      isRecurring: row.isRecurring,
    );
  }

  static ExpensesCompanion toCompanion(Expense expense) {
    return ExpensesCompanion(
      id: Value(expense.id),
      amount: Value(expense.amount),
      categoryId: Value(expense.categoryId),
      note: Value(expense.note),
      date: Value(expense.date),
      paymentMethod: Value(expense.paymentMethod.name),
      isRecurring: Value(expense.isRecurring),
    );
  }
}
