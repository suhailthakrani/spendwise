import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../mappers/template_mapper.dart';
import '../models/transaction_template.dart';

class TemplateRepository {
  TemplateRepository(this._db, this._userId);

  final AppDatabase _db;
  final String _userId;
  static const _uuid = Uuid();

  Stream<List<TransactionTemplate>> watchAll() {
    return (_db.select(_db.transactionTemplates)
          ..where((t) => t.userId.equals(_userId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.isFavourite),
            (t) => OrderingTerm.desc(t.useCount),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch()
        .map((rows) => rows.map(TemplateMapper.fromRow).toList());
  }

  Stream<List<TransactionTemplate>> watchFavourites() {
    return (_db.select(_db.transactionTemplates)
          ..where(
            (t) => t.userId.equals(_userId) & t.isFavourite.equals(true),
          )
          ..orderBy([
            (t) => OrderingTerm.desc(t.useCount),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch()
        .map((rows) => rows.map(TemplateMapper.fromRow).toList());
  }

  Future<void> create(TransactionTemplate template) async {
    await _db.into(_db.transactionTemplates).insert(
          TemplateMapper.toCompanion(template, userId: _userId),
        );
  }

  Future<void> update(TransactionTemplate template) async {
    await (_db.update(_db.transactionTemplates)
          ..where((t) => t.id.equals(template.id) & t.userId.equals(_userId)))
        .write(
      TransactionTemplatesCompanion(
        name: Value(template.name),
        amount: Value(template.amount),
        categoryId: Value(template.categoryId),
        type: Value(template.type.name),
        note: Value(template.note),
        paymentMethod: Value(template.paymentMethod.name),
        isFavourite: Value(template.isFavourite),
        useCount: Value(template.useCount),
        lastUsedAt: Value(template.lastUsedAt),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.transactionTemplates)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .go();
  }

  Future<void> markUsed(String id) async {
    final row = await (_db.select(_db.transactionTemplates)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .getSingleOrNull();
    if (row == null) return;

    await (_db.update(_db.transactionTemplates)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .write(
      TransactionTemplatesCompanion(
        useCount: Value(row.useCount + 1),
        lastUsedAt: Value(DateTime.now()),
      ),
    );
  }

  String newId() => _uuid.v4();
}
