import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/payment_method.dart';
import '../models/recurring_expense.dart';

abstract final class RecurringExpenseMapper {
  static RecurringExpense fromRow(RecurringExpenseRow row) {
    return RecurringExpense(
      id: row.id,
      title: row.title,
      amount: row.amount,
      categoryId: row.categoryId,
      frequency: RecurrenceFrequency.values.byName(row.frequency),
      nextDueDate: row.nextDueDate,
      paymentMethod: PaymentMethod.values.byName(row.paymentMethod),
    );
  }

  static RecurringExpensesCompanion toCompanion(RecurringExpense expense) {
    return RecurringExpensesCompanion(
      id: Value(expense.id),
      title: Value(expense.title),
      amount: Value(expense.amount),
      categoryId: Value(expense.categoryId),
      frequency: Value(expense.frequency.name),
      nextDueDate: Value(expense.nextDueDate),
      paymentMethod: Value(expense.paymentMethod.name),
    );
  }
}
