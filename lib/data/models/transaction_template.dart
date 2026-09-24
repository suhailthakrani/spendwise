import 'ledger_entry_type.dart';
import 'payment_method.dart';

class TransactionTemplate {
  const TransactionTemplate({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.note,
    required this.paymentMethod,
    required this.isFavourite,
    required this.useCount,
    this.lastUsedAt,
  });

  final String id;
  final String name;
  /// Stored in the app's base currency (USD).
  final double amount;
  final String categoryId;
  final LedgerEntryType type;
  final String note;
  final PaymentMethod paymentMethod;
  final bool isFavourite;
  final int useCount;
  final DateTime? lastUsedAt;

  TransactionTemplate copyWith({
    String? id,
    String? name,
    double? amount,
    String? categoryId,
    LedgerEntryType? type,
    String? note,
    PaymentMethod? paymentMethod,
    bool? isFavourite,
    int? useCount,
    DateTime? lastUsedAt,
    bool clearLastUsedAt = false,
  }) {
    return TransactionTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isFavourite: isFavourite ?? this.isFavourite,
      useCount: useCount ?? this.useCount,
      lastUsedAt: clearLastUsedAt ? null : (lastUsedAt ?? this.lastUsedAt),
    );
  }
}
