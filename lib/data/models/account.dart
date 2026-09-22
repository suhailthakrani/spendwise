import 'account_type.dart';

class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.openingBalance,
    required this.isDefault,
    this.balance,
  });

  final String id;
  final String name;
  final AccountType type;
  /// Base-currency (USD) opening balance.
  final double openingBalance;
  final bool isDefault;

  /// Derived ledger balance when loaded via the repository; null when not computed.
  final double? balance;

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? openingBalance,
    bool? isDefault,
    double? balance,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      openingBalance: openingBalance ?? this.openingBalance,
      isDefault: isDefault ?? this.isDefault,
      balance: balance ?? this.balance,
    );
  }
}
