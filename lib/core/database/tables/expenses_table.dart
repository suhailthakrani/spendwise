import 'package:drift/drift.dart';

import 'accounts_table.dart';
import 'categories_table.dart';

/// Ledger row. Table kept as `expenses` so existing installs migrate in place;
/// [type] distinguishes expense / income / transfer.
@DataClassName('ExpenseRow')
@TableIndex(name: 'idx_expenses_user_date', columns: {#userId, #date})
@TableIndex(name: 'idx_expenses_user_category', columns: {#userId, #categoryId})
@TableIndex(name: 'idx_expenses_user_type', columns: {#userId, #type})
@TableIndex(name: 'idx_expenses_user_account', columns: {#userId, #accountId})
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get userId =>
      text().withDefault(const Constant('profile_main'))();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get date => dateTime()();
  TextColumn get paymentMethod => text()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();

  /// expense | income | transfer
  TextColumn get type => text().withDefault(const Constant('expense'))();
  /// Wallet this entry hits. Default only exists so schema upgrades can add
  /// the column; the app always writes a real account id on create.
  TextColumn get accountId => text()
      .withDefault(const Constant(''))
      .references(Accounts, #id)();
  /// Destination account when [type] is transfer; otherwise null.
  @ReferenceName('transferDestination')
  TextColumn get toAccountId => text().nullable().references(Accounts, #id)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
