import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/envelope.dart';

abstract final class EnvelopeMapper {
  static Envelope fromRow(EnvelopeRow row) {
    return Envelope(
      id: row.id,
      name: row.name,
      allocated: row.allocated,
      spent: row.spent,
      categoryId: row.categoryId,
      year: row.year,
      month: row.month,
    );
  }

  static EnvelopesCompanion toCompanion(
    Envelope envelope, {
    required String userId,
  }) {
    return EnvelopesCompanion(
      id: Value(envelope.id),
      userId: Value(userId),
      name: Value(envelope.name),
      allocated: Value(envelope.allocated),
      spent: Value(envelope.spent),
      categoryId: Value(envelope.categoryId),
      year: Value(envelope.year),
      month: Value(envelope.month),
    );
  }
}
