import 'package:drift/drift.dart';

import 'categories_table.dart';

@DataClassName('ExpenseRow')
class Expenses extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  TextColumn get paymentMethod => text()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
