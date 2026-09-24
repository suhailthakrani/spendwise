import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/ledger_entry_type.dart';
import '../models/payment_method.dart';
import '../models/transaction_template.dart';

abstract final class TemplateMapper {
  static TransactionTemplate fromRow(TransactionTemplateRow row) {
    return TransactionTemplate(
      id: row.id,
      name: row.name,
      amount: row.amount,
      categoryId: row.categoryId,
      type: LedgerEntryType.fromDb(row.type),
      note: row.note,
      paymentMethod: PaymentMethod.values.byName(row.paymentMethod),
      isFavourite: row.isFavourite,
      useCount: row.useCount,
      lastUsedAt: row.lastUsedAt,
    );
  }

  static TransactionTemplatesCompanion toCompanion(
    TransactionTemplate template, {
    required String userId,
  }) {
    return TransactionTemplatesCompanion(
      id: Value(template.id),
      userId: Value(userId),
      name: Value(template.name),
      amount: Value(template.amount),
      categoryId: Value(template.categoryId),
      type: Value(template.type.name),
      note: Value(template.note),
      paymentMethod: Value(template.paymentMethod.name),
      isFavourite: Value(template.isFavourite),
      useCount: Value(template.useCount),
      lastUsedAt: Value(template.lastUsedAt),
    );
  }
}
