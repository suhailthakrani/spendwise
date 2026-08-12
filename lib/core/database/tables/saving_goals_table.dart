import 'package:drift/drift.dart';

@DataClassName('SavingGoalRow')
class SavingGoals extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().withDefault(const Constant('profile_main'))();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  DateTimeColumn get deadline => dateTime().nullable()();
  RealColumn get monthlyTarget => real().nullable()();
  TextColumn get wishlistTitle => text().nullable()();
  TextColumn get wishlistNote => text().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
