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

  /// Moves every reference from [fromId] into [intoId], then deletes [fromId].
  ///
  /// Safe no-op when ids match or either category is missing. Runs in one
  /// transaction so a failure never leaves half-merged data.
  Future<void> mergeInto({
    required String fromId,
    required String intoId,
  }) async {
    if (fromId == intoId) return;

    final from = await getById(fromId);
    final into = await getById(intoId);
    if (from == null || into == null) {
      throw StateError('Both categories must exist to merge');
    }

    await _db.transaction(() async {
      await (_db.update(_db.expenses)
            ..where(
              (t) => t.userId.equals(_userId) & t.categoryId.equals(fromId),
            ))
          .write(ExpensesCompanion(categoryId: Value(intoId)));

      await (_db.update(_db.budgets)
            ..where(
              (t) => t.userId.equals(_userId) & t.categoryId.equals(fromId),
            ))
          .write(BudgetsCompanion(categoryId: Value(intoId)));

      await (_db.update(_db.recurringExpenses)
            ..where(
              (t) => t.userId.equals(_userId) & t.categoryId.equals(fromId),
            ))
          .write(RecurringExpensesCompanion(categoryId: Value(intoId)));

      await (_db.update(_db.transactionTemplates)
            ..where(
              (t) => t.userId.equals(_userId) & t.categoryId.equals(fromId),
            ))
          .write(TransactionTemplatesCompanion(categoryId: Value(intoId)));

      await (_db.update(_db.envelopes)
            ..where(
              (t) => t.userId.equals(_userId) & t.categoryId.equals(fromId),
            ))
          .write(EnvelopesCompanion(categoryId: Value(intoId)));

      await (_db.update(_db.userSettings)
            ..where(
              (t) =>
                  t.userId.equals(_userId) &
                  t.defaultCategoryId.equals(fromId),
            ))
          .write(UserSettingsCompanion(defaultCategoryId: Value(intoId)));
      await (_db.update(_db.userSettings)
            ..where(
              (t) =>
                  t.userId.equals(_userId) &
                  t.lastUsedCategoryId.equals(fromId),
            ))
          .write(UserSettingsCompanion(lastUsedCategoryId: Value(intoId)));

      await (_db.delete(_db.categories)
            ..where((t) => t.id.equals(fromId) & t.userId.equals(_userId)))
          .go();
    });
  }

  String newId() => 'cat_${_uuid.v4()}';
}
