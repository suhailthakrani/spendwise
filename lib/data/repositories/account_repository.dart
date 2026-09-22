import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_seed.dart';
import '../mappers/account_mapper.dart';
import '../models/account.dart';
import '../models/account_type.dart';
import '../models/ledger_entry_type.dart';

class AccountRepository {
  AccountRepository(this._db, this._userId);

  final AppDatabase _db;
  final String _userId;
  static const _uuid = Uuid();

  Stream<List<Account>> watchAll() {
    return (_db.select(_db.accounts)
          ..where((t) => t.userId.equals(_userId))
          ..orderBy([
            (t) => OrderingTerm.desc(t.isDefault),
            (t) => OrderingTerm.asc(t.name),
          ]))
        .watch()
        .asyncMap((rows) async {
      final accounts = <Account>[];
      for (final row in rows) {
        final balance = await balanceFor(row.id, opening: row.openingBalance);
        accounts.add(AccountMapper.fromRow(row, balance: balance));
      }
      return accounts;
    });
  }

  Future<Account?> getDefault() async {
    await seedAccountsForUser(_db, _userId);
    final row = await (_db.select(_db.accounts)
          ..where(
            (t) => t.userId.equals(_userId) & t.isDefault.equals(true),
          ))
        .getSingleOrNull();
    if (row == null) return null;
    final balance = await balanceFor(row.id, opening: row.openingBalance);
    return AccountMapper.fromRow(row, balance: balance);
  }

  Future<Account?> getById(String id) async {
    final row = await (_db.select(_db.accounts)
          ..where((t) => t.id.equals(id) & t.userId.equals(_userId)))
        .getSingleOrNull();
    if (row == null) return null;
    final balance = await balanceFor(row.id, opening: row.openingBalance);
    return AccountMapper.fromRow(row, balance: balance);
  }

  /// Sum of opening + income − expense − transfers out + transfers in.
  Future<double> balanceFor(String accountId, {double? opening}) async {
    final row = await (_db.select(_db.accounts)
          ..where((t) => t.id.equals(accountId) & t.userId.equals(_userId)))
        .getSingleOrNull();
    final openingBalance = opening ?? row?.openingBalance ?? 0;

    final entries = await (_db.select(_db.expenses)
          ..where(
            (t) =>
                t.userId.equals(_userId) &
                (t.accountId.equals(accountId) |
                    t.toAccountId.equals(accountId)),
          ))
        .get();

    var balance = openingBalance;
    for (final entry in entries) {
      final type = LedgerEntryType.fromDb(entry.type);
      switch (type) {
        case LedgerEntryType.income:
          if (entry.accountId == accountId) balance += entry.amount;
        case LedgerEntryType.expense:
          if (entry.accountId == accountId) balance -= entry.amount;
        case LedgerEntryType.transfer:
          if (entry.accountId == accountId) balance -= entry.amount;
          if (entry.toAccountId == accountId) balance += entry.amount;
      }
    }
    return balance;
  }

  /// Total money across all accounts — what people mean by "my balance".
  Future<double> totalBalance() async {
    final rows = await (_db.select(_db.accounts)
          ..where((t) => t.userId.equals(_userId)))
        .get();
    var total = 0.0;
    for (final row in rows) {
      total += await balanceFor(row.id, opening: row.openingBalance);
    }
    return total;
  }

  Future<void> create({
    required String name,
    required AccountType type,
    double openingBalance = 0,
    bool makeDefault = false,
  }) async {
    if (makeDefault) {
      await (_db.update(_db.accounts)
            ..where((t) => t.userId.equals(_userId)))
          .write(const AccountsCompanion(isDefault: Value(false)));
    }
    await _db.into(_db.accounts).insert(
          AccountsCompanion.insert(
            id: _uuid.v4(),
            userId: _userId,
            name: name.trim().isEmpty ? type.label : name.trim(),
            type: type.name,
            openingBalance: Value(openingBalance),
            isDefault: Value(makeDefault),
          ),
        );
  }

  Future<void> ensureSeeded() => seedAccountsForUser(_db, _userId);
}
