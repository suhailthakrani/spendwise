import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../mappers/category_mapper.dart';
import '../models/category.dart';

class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<ExpenseCategory>> watchAll() {
    return (_db.select(_db.categories)..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(CategoryMapper.fromRow).toList());
  }

  Future<ExpenseCategory?> getById(String id) async {
    final row = await (_db.select(_db.categories)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : CategoryMapper.fromRow(row);
  }

  Future<void> create(ExpenseCategory category) async {
    await _db.into(_db.categories).insert(CategoryMapper.toCompanion(category));
  }

  Future<void> update(ExpenseCategory category) async {
    await _db
        .update(_db.categories)
        .replace(CategoryMapper.toCompanion(category));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
  }

  String newId() => 'cat_${_uuid.v4()}';
}
