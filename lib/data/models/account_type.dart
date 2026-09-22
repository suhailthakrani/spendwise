/// cash | bank | card | wallet — the accounts people actually use day to day.
enum AccountType {
  cash,
  bank,
  card,
  wallet;

  static AccountType fromDb(String value) {
    for (final type in AccountType.values) {
      if (type.name == value) return type;
    }
    return AccountType.cash;
  }

  String get label => switch (this) {
        AccountType.cash => 'Cash',
        AccountType.bank => 'Bank',
        AccountType.card => 'Card',
        AccountType.wallet => 'Wallet',
      };
}
