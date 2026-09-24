import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

/// Money in or out that is recorded but kept out of budgets and expense totals.
/// [direction] is `out` or `in`.
@DataClassName('MoneyLogRow')
@TableIndex(name: 'idx_money_logs_user_date', columns: {#userId, #date})
class MoneyLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(UserProfiles, #id)();
  RealColumn get amount => real()();
  TextColumn get message => text()();
  DateTimeColumn get date => dateTime()();

  /// `out` (default) or `in`.
  TextColumn get direction => text().withDefault(const Constant('out'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
