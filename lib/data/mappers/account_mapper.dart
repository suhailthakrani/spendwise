import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/account.dart';
import '../models/account_type.dart';

abstract final class AccountMapper {
  static Account fromRow(AccountRow row, {double? balance}) {
    return Account(
      id: row.id,
      name: row.name,
      type: AccountType.fromDb(row.type),
      openingBalance: row.openingBalance,
      isDefault: row.isDefault,
      balance: balance,
    );
  }

  static AccountsCompanion toCompanion(
    Account account, {
    required String userId,
  }) {
    return AccountsCompanion(
      id: Value(account.id),
      userId: Value(userId),
      name: Value(account.name),
      type: Value(account.type.name),
      openingBalance: Value(account.openingBalance),
      isDefault: Value(account.isDefault),
    );
  }
}
