import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

/// Spending that is recorded but kept out of budgets and expense totals.
@DataClassName('MoneyLogRow')
@TableIndex(name: 'idx_money_logs_user_date', columns: {#userId, #date})
class MoneyLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(UserProfiles, #id)();
  RealColumn get amount => real()();
  TextColumn get message => text()();
  DateTimeColumn get date => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
