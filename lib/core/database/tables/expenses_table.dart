import 'package:drift/drift.dart';

import 'categories_table.dart';

/// Ledger row. Table kept as `expenses` so existing installs migrate in place;
/// [type] distinguishes expense / income.
@DataClassName('ExpenseRow')
@TableIndex(name: 'idx_expenses_user_date', columns: {#userId, #date})
@TableIndex(name: 'idx_expenses_user_category', columns: {#userId, #categoryId})
@TableIndex(name: 'idx_expenses_user_type', columns: {#userId, #type})
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().withDefault(const Constant('profile_main'))();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  TextColumn get paymentMethod => text()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  /// expense | income
  TextColumn get type => text().withDefault(const Constant('expense'))();

  /// Comma-separated tags for search and filtering.
  TextColumn get tags => text().withDefault(const Constant(''))();
  /// Local file path for an attached receipt image (OCR deferred).
  TextColumn get attachmentPath => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
