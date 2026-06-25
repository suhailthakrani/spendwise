import 'payment_method.dart';

enum RecurrenceFrequency { weekly, monthly, yearly }

class RecurringExpense {
  const RecurringExpense({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.frequency,
    required this.nextDueDate,
    required this.paymentMethod,
  });

  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final RecurrenceFrequency frequency;
  final DateTime nextDueDate;
  final PaymentMethod paymentMethod;
}
