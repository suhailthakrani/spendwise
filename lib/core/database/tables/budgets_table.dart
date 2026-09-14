import 'package:drift/drift.dart';

import 'categories_table.dart';

@DataClassName('BudgetRow')
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

  @override
  Set<Column<Object>> get primaryKey => {id};
}
