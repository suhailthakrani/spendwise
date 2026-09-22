import 'ledger_entry_type.dart';
import 'payment_method.dart';

class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.note,
    required this.date,
    required this.paymentMethod,
    required this.accountId,
    this.type = LedgerEntryType.expense,
    this.toAccountId,
    this.isRecurring = false,
  });

  final String id;
  /// Stored in the app's base currency (USD). Display uses global preference.
  final double amount;
  final String categoryId;
  final String note;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String accountId;
  final LedgerEntryType type;
  final String? toAccountId;
  final bool isRecurring;

  bool get isExpense => type == LedgerEntryType.expense;
  bool get isIncome => type == LedgerEntryType.income;

  Expense copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? note,
    DateTime? date,
    PaymentMethod? paymentMethod,
    String? accountId,
    LedgerEntryType? type,
    String? toAccountId,
    bool clearToAccountId = false,
    bool? isRecurring,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      toAccountId:
          clearToAccountId ? null : (toAccountId ?? this.toAccountId),
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}
