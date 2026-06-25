import 'package:drift/drift.dart';

import 'categories_table.dart';

@DataClassName('BudgetRow')
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get limitAmount => real()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  BoolColumn get isMonthly => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
