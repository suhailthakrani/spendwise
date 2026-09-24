import 'ledger_entry_type.dart';
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
    this.entryType = LedgerEntryType.expense,
    this.autoPost = false,
  });

  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final RecurrenceFrequency frequency;
  final DateTime nextDueDate;
  final PaymentMethod paymentMethod;
  final LedgerEntryType entryType;
  final bool autoPost;

  RecurringExpense copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    RecurrenceFrequency? frequency,
    DateTime? nextDueDate,
    PaymentMethod? paymentMethod,
    LedgerEntryType? entryType,
    bool? autoPost,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      entryType: entryType ?? this.entryType,
      autoPost: autoPost ?? this.autoPost,
    );
  }
}
