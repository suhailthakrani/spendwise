import 'package:drift/drift.dart';

import 'categories_table.dart';
import 'user_profiles_table.dart';

/// Envelope allocation buckets for budgeting v2.
@DataClassName('EnvelopeRow')
@TableIndex(name: 'idx_envelopes_user', columns: {#userId})
class Envelopes extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(UserProfiles, #id)();
  TextColumn get name => text()();
  RealColumn get allocated => real().withDefault(const Constant(0.0))();
  RealColumn get spent => real().withDefault(const Constant(0.0))();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  IntColumn get year => integer()();
  IntColumn get month => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
