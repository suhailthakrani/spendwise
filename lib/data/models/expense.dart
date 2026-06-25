import 'payment_method.dart';

class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.date,
    required this.paymentMethod,
    this.isRecurring = false,
  });

  final String id;
  /// Stored in the app's base currency (USD). Display uses global preference.
  final double amount;
  final String categoryId;
  final String note;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final bool isRecurring;

  Expense copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? note,
    DateTime? date,
    PaymentMethod? paymentMethod,
    bool? isRecurring,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}
