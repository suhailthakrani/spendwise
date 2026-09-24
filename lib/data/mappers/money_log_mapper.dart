import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/money_log.dart';

abstract final class MoneyLogMapper {
  static MoneyLog fromRow(MoneyLogRow row) {
    return MoneyLog(
      id: row.id,
      amount: row.amount,
      message: row.message,
      date: row.date,
      direction: MoneyLogDirection.fromStorage(row.direction),
    );
  }

  static MoneyLogsCompanion toCompanion(
    MoneyLog log, {
    required String userId,
  }) {
    return MoneyLogsCompanion(
      id: Value(log.id),
      userId: Value(userId),
      amount: Value(log.amount),
      message: Value(log.message),
      date: Value(log.date),
      direction: Value(log.direction.storageValue),
    );
  }
}
