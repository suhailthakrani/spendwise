import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../mappers/money_log_mapper.dart';
import '../models/money_log.dart';

class MoneyLogRepository {
  MoneyLogRepository(this._db, this._userId);

  final AppDatabase _db;
  final String _userId;
  static const _uuid = Uuid();

  String newId() => _uuid.v4();

  Stream<List<MoneyLog>> watchAll() {
    return (_db.select(_db.moneyLogs)
          ..where((t) => t.userId.equals(_userId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch()
        .map((rows) => rows.map(MoneyLogMapper.fromRow).toList());
  }

  Future<void> create(MoneyLog log) async {
    await _db.into(_db.moneyLogs).insert(
          MoneyLogMapper.toCompanion(log, userId: _userId),
        );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.moneyLogs)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .go();
  }
}
