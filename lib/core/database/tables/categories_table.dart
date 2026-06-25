import 'package:drift/drift.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get iconName => text()();
  IntColumn get colorValue => integer()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  RealColumn get budgetLimit => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
