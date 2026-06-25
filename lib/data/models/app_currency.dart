class AppCurrency {
  const AppCurrency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimalDigits,
    required this.rateFromUsd,
  });

  final String code;
  final String name;
  final String symbol;
  final int decimalDigits;
  final double rateFromUsd;

  static const usd = AppCurrency(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    decimalDigits: 2,
    rateFromUsd: 1.0,
  );

  static const pkr = AppCurrency(
    code: 'PKR',
    name: 'Pakistani Rupee',
    symbol: 'Rs',
    decimalDigits: 0,
    rateFromUsd: 278.0,
  );

  static const inr = AppCurrency(
    code: 'INR',
    name: 'Indian Rupee',
    symbol: '₹',
    decimalDigits: 0,
    rateFromUsd: 83.5,
  );

  static const eur = AppCurrency(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    decimalDigits: 2,
    rateFromUsd: 0.92,
  );

  static const aed = AppCurrency(
    code: 'AED',
    name: 'UAE Dirham',
    symbol: 'د.إ',
    decimalDigits: 2,
    rateFromUsd: 3.67,
  );

  static const List<AppCurrency> all = [usd, pkr, inr, eur, aed];

  static AppCurrency byCode(String code) {
    return all.firstWhere(
      (c) => c.code == code,
      orElse: () => usd,
    );
  }
}
