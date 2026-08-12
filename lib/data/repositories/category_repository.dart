import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../mappers/category_mapper.dart';
import '../models/category.dart';

class CategoryRepository {
  CategoryRepository(this._db, this._userId);

  final AppDatabase _db;
  final String _userId;
  static const _uuid = Uuid();

  Stream<List<ExpenseCategory>> watchAll() {
    return (_db.select(_db.categories)
          ..where((t) => t.userId.equals(_userId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(CategoryMapper.fromRow).toList());
  }

  Future<ExpenseCategory?> getById(String id) async {
    final row = await (_db.select(_db.categories)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .getSingleOrNull();
    return row == null ? null : CategoryMapper.fromRow(row);
  }

  Future<void> create(ExpenseCategory category) async {
    await _db.into(_db.categories).insert(
          CategoryMapper.toCompanion(category, userId: _userId),
        );
  }

  Future<void> update(ExpenseCategory category) async {
    await (_db.update(_db.categories)
          ..where((t) => t.id.equals(category.id) & t.userId.equals(_userId)))
        .write(
      CategoriesCompanion(
        name: Value(category.name),
        iconName: Value(category.iconName),
        colorValue: Value(category.color.toARGB32()),
        isCustom: Value(category.isCustom),
        budgetLimit: Value(category.budgetLimit),
      ),
    );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.categories)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .go();
  }

  String newId() => 'cat_${_uuid.v4()}';
}
