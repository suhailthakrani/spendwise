import 'package:drift/drift.dart';

import 'categories_table.dart';

@DataClassName('BudgetRow')
@TableIndex(name: 'idx_budgets_user_period', columns: {#userId, #year, #month})
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().withDefault(const Constant('profile_main'))();
  TextColumn get name => text()();
  RealColumn get limitAmount => real()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  BoolColumn get isMonthly => boolean().withDefault(const Constant(true))();
  /// Calendar year this budget applies to (e.g. 2026).
  IntColumn get year => integer()();
  /// Calendar month this budget applies to (1–12).
  IntColumn get month => integer()();

  /// weekly | monthly | yearly | custom | event
  TextColumn get periodType => text().withDefault(const Constant('monthly'))();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get rolloverEnabled =>
      boolean().withDefault(const Constant(false))();
  /// Unused amount carried from the previous period (USD).
  RealColumn get rolloverAmount => real().withDefault(const Constant(0.0))();
  /// Soft spending limit distinct from a hard budget envelope.
  BoolColumn get isSpendingLimit =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
