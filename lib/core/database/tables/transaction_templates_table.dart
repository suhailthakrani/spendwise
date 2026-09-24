import 'package:drift/drift.dart';

import 'categories_table.dart';
import 'user_profiles_table.dart';

/// Saved amount + category shortcuts for ultra-fast capture.
@DataClassName('TransactionTemplateRow')
@TableIndex(name: 'idx_templates_user', columns: {#userId})
class TransactionTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(UserProfiles, #id)();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().references(Categories, #id)();
  /// expense | income
  TextColumn get type => text().withDefault(const Constant('expense'))();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get paymentMethod => text()();
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();
  IntColumn get useCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
