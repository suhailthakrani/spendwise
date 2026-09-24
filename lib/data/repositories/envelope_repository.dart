import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../mappers/envelope_mapper.dart';
import '../models/envelope.dart';

class EnvelopeRepository {
  EnvelopeRepository(this._db, this._userId);

  final AppDatabase _db;
  final String _userId;
  static const _uuid = Uuid();

  Stream<List<Envelope>> watchAll() {
    return (_db.select(_db.envelopes)
          ..where((t) => t.userId.equals(_userId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.year),
            (t) => OrderingTerm.desc(t.month),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch()
        .map((rows) => rows.map(EnvelopeMapper.fromRow).toList());
  }

  Future<void> create(Envelope envelope) async {
    await _db.into(_db.envelopes).insert(
          EnvelopeMapper.toCompanion(envelope, userId: _userId),
        );
  }

  Future<void> update(Envelope envelope) async {
    await (_db.update(_db.envelopes)
          ..where((t) => t.id.equals(envelope.id) & t.userId.equals(_userId)))
        .write(
      EnvelopesCompanion(
        name: Value(envelope.name),
        allocated: Value(envelope.allocated),
        spent: Value(envelope.spent),
        categoryId: Value(envelope.categoryId),
        year: Value(envelope.year),
        month: Value(envelope.month),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.envelopes)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .go();
  }

  /// Moves [amount] of allocation from one envelope to another.
  Future<void> reallocate({
    required String fromId,
    required String toId,
    required double amount,
  }) async {
    if (amount <= 0) {
      throw StateError('Reallocation amount must be positive');
    }
    if (fromId == toId) {
      throw StateError('Cannot reallocate an envelope to itself');
    }

    await _db.transaction(() async {
      final from = await (_db.select(_db.envelopes)
            ..where((t) => t.id.equals(fromId) & t.userId.equals(_userId)))
          .getSingleOrNull();
      final to = await (_db.select(_db.envelopes)
            ..where((t) => t.id.equals(toId) & t.userId.equals(_userId)))
          .getSingleOrNull();
      if (from == null || to == null) {
        throw StateError('Envelope not found');
      }
      if (from.allocated < amount) {
        throw StateError('Not enough allocated amount to reallocate');
      }

      await (_db.update(_db.envelopes)
            ..where((t) => t.id.equals(fromId) & t.userId.equals(_userId)))
          .write(
        EnvelopesCompanion(allocated: Value(from.allocated - amount)),
      );
      await (_db.update(_db.envelopes)
            ..where((t) => t.id.equals(toId) & t.userId.equals(_userId)))
          .write(
        EnvelopesCompanion(allocated: Value(to.allocated + amount)),
      );
    });
  }

  String newId() => _uuid.v4();
}
