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
    this.type = LedgerEntryType.expense,
    this.isRecurring = false,
    this.tags = const [],
    this.attachmentPath,
  });

  final String id;
  /// Stored in the app's base currency (USD). Display uses global preference.
  final double amount;
  final String categoryId;
  final String note;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final LedgerEntryType type;
  final bool isRecurring;
  final List<String> tags;
  final String? attachmentPath;

  bool get isExpense => type == LedgerEntryType.expense;
  bool get isIncome => type == LedgerEntryType.income;

  /// Comma-separated form used in the DB column.
  String get tagsCsv => tags.join(',');

  /// Parses a DB tags column into a trimmed, non-empty list.
  static List<String> parseTags(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    return raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList(growable: false);
  }

  Expense copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? note,
    DateTime? date,
    PaymentMethod? paymentMethod,
    LedgerEntryType? type,
    bool? isRecurring,
    List<String>? tags,
    String? attachmentPath,
    bool clearAttachmentPath = false,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      type: type ?? this.type,
      isRecurring: isRecurring ?? this.isRecurring,
      tags: tags ?? this.tags,
      attachmentPath: clearAttachmentPath
          ? null
          : (attachmentPath ?? this.attachmentPath),
    );
  }
}
