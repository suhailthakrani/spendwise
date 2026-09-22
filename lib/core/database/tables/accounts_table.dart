import 'package:drift/drift.dart';

import 'user_profiles_table.dart';

/// Wallet / cash / bank / card the user records money against.
///
/// Balance is never stored as a mutable total — it is derived from
/// [openingBalance] plus ledger rows for this account.
@DataClassName('AccountRow')
@TableIndex(name: 'idx_accounts_user', columns: {#userId})
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(UserProfiles, #id)();
  TextColumn get name => text()();
  /// cash | bank | card | wallet
  TextColumn get type => text()();
  /// Opening balance in the app base currency (USD), same as expenses.amount.
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
