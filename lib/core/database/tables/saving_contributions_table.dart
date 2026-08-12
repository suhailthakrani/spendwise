import 'package:drift/drift.dart';

import 'saving_goals_table.dart';

@DataClassName('SavingContributionRow')
class SavingContributions extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().withDefault(const Constant('profile_main'))();
  TextColumn get goalId => text().references(SavingGoals, #id)();
  RealColumn get amount => real()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
