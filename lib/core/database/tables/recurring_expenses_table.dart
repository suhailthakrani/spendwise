import 'package:drift/drift.dart';

import 'categories_table.dart';

@DataClassName('RecurringExpenseRow')
@TableIndex(name: 'idx_recurring_user_due', columns: {#userId, #nextDueDate})
class RecurringExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().withDefault(const Constant('profile_main'))();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get frequency => text()();
  DateTimeColumn get nextDueDate => dateTime()();
  TextColumn get paymentMethod => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
