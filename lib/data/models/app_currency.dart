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

  /// Approximate units per 1 USD (display conversion only).
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

  static AppCurrency byCode(String code) {
    final upper = code.toUpperCase();
    for (final currency in all) {
      if (currency.code == upper) return currency;
    }
    return usd;
  }

  static List<AppCurrency> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q) ||
              c.symbol.toLowerCase().contains(q),
        )
        .toList();
  }

  static const List<AppCurrency> all = [
    usd,
    AppCurrency(
        code: 'EUR',
        name: 'Euro',
        symbol: '€',
        decimalDigits: 2,
        rateFromUsd: 0.92),
    AppCurrency(
        code: 'GBP',
        name: 'British Pound',
        symbol: '£',
        decimalDigits: 2,
        rateFromUsd: 0.79),
    AppCurrency(
        code: 'JPY',
        name: 'Japanese Yen',
        symbol: '¥',
        decimalDigits: 0,
        rateFromUsd: 157.0),
    AppCurrency(
        code: 'CNY',
        name: 'Chinese Yuan',
        symbol: '¥',
        decimalDigits: 2,
        rateFromUsd: 7.25),
    AppCurrency(
        code: 'AUD',
        name: 'Australian Dollar',
        symbol: 'A\$',
        decimalDigits: 2,
        rateFromUsd: 1.53),
    AppCurrency(
        code: 'CAD',
        name: 'Canadian Dollar',
        symbol: 'C\$',
        decimalDigits: 2,
        rateFromUsd: 1.37),
    AppCurrency(
        code: 'CHF',
        name: 'Swiss Franc',
        symbol: 'CHF',
        decimalDigits: 2,
        rateFromUsd: 0.88),
    AppCurrency(
        code: 'HKD',
        name: 'Hong Kong Dollar',
        symbol: 'HK\$',
        decimalDigits: 2,
        rateFromUsd: 7.82),
    AppCurrency(
        code: 'SGD',
        name: 'Singapore Dollar',
        symbol: 'S\$',
        decimalDigits: 2,
        rateFromUsd: 1.34),
    AppCurrency(
        code: 'NZD',
        name: 'New Zealand Dollar',
        symbol: 'NZ\$',
        decimalDigits: 2,
        rateFromUsd: 1.67),
    AppCurrency(
        code: 'SEK',
        name: 'Swedish Krona',
        symbol: 'kr',
        decimalDigits: 2,
        rateFromUsd: 10.6),
    AppCurrency(
        code: 'NOK',
        name: 'Norwegian Krone',
        symbol: 'kr',
        decimalDigits: 2,
        rateFromUsd: 10.8),
    AppCurrency(
        code: 'DKK',
        name: 'Danish Krone',
        symbol: 'kr',
        decimalDigits: 2,
        rateFromUsd: 6.9),
    AppCurrency(
        code: 'PLN',
        name: 'Polish Zloty',
        symbol: 'zł',
        decimalDigits: 2,
        rateFromUsd: 3.95),
    AppCurrency(
        code: 'CZK',
        name: 'Czech Koruna',
        symbol: 'Kč',
        decimalDigits: 2,
        rateFromUsd: 23.2),
    AppCurrency(
        code: 'HUF',
        name: 'Hungarian Forint',
        symbol: 'Ft',
        decimalDigits: 0,
        rateFromUsd: 365.0),
    AppCurrency(
        code: 'RON',
        name: 'Romanian Leu',
        symbol: 'lei',
        decimalDigits: 2,
        rateFromUsd: 4.6),
    AppCurrency(
        code: 'TRY',
        name: 'Turkish Lira',
        symbol: '₺',
        decimalDigits: 2,
        rateFromUsd: 34.0),
    AppCurrency(
        code: 'RUB',
        name: 'Russian Ruble',
        symbol: '₽',
        decimalDigits: 2,
        rateFromUsd: 92.0),
    AppCurrency(
        code: 'UAH',
        name: 'Ukrainian Hryvnia',
        symbol: '₴',
        decimalDigits: 2,
        rateFromUsd: 41.0),
    AppCurrency(
        code: 'INR',
        name: 'Indian Rupee',
        symbol: '₹',
        decimalDigits: 0,
        rateFromUsd: 83.5),
    pkr,
    AppCurrency(
        code: 'BDT',
        name: 'Bangladeshi Taka',
        symbol: '৳',
        decimalDigits: 2,
        rateFromUsd: 110.0),
    AppCurrency(
        code: 'LKR',
        name: 'Sri Lankan Rupee',
        symbol: 'Rs',
        decimalDigits: 2,
        rateFromUsd: 300.0),
    AppCurrency(
        code: 'NPR',
        name: 'Nepalese Rupee',
        symbol: 'Rs',
        decimalDigits: 2,
        rateFromUsd: 133.0),
    AppCurrency(
        code: 'AED',
        name: 'UAE Dirham',
        symbol: 'د.إ',
        decimalDigits: 2,
        rateFromUsd: 3.67),
    AppCurrency(
        code: 'SAR',
        name: 'Saudi Riyal',
        symbol: '﷼',
        decimalDigits: 2,
        rateFromUsd: 3.75),
    AppCurrency(
        code: 'QAR',
        name: 'Qatari Riyal',
        symbol: '﷼',
        decimalDigits: 2,
        rateFromUsd: 3.64),
    AppCurrency(
        code: 'KWD',
        name: 'Kuwaiti Dinar',
        symbol: 'د.ك',
        decimalDigits: 3,
        rateFromUsd: 0.31),
    AppCurrency(
        code: 'BHD',
        name: 'Bahraini Dinar',
        symbol: 'BD',
        decimalDigits: 3,
        rateFromUsd: 0.38),
    AppCurrency(
        code: 'OMR',
        name: 'Omani Rial',
        symbol: '﷼',
        decimalDigits: 3,
        rateFromUsd: 0.39),
    AppCurrency(
        code: 'JOD',
        name: 'Jordanian Dinar',
        symbol: 'JD',
        decimalDigits: 3,
        rateFromUsd: 0.71),
    AppCurrency(
        code: 'ILS',
        name: 'Israeli Shekel',
        symbol: '₪',
        decimalDigits: 2,
        rateFromUsd: 3.7),
    AppCurrency(
        code: 'EGP',
        name: 'Egyptian Pound',
        symbol: 'E£',
        decimalDigits: 2,
        rateFromUsd: 48.0),
    AppCurrency(
        code: 'ZAR',
        name: 'South African Rand',
        symbol: 'R',
        decimalDigits: 2,
        rateFromUsd: 18.2),
    AppCurrency(
        code: 'NGN',
        name: 'Nigerian Naira',
        symbol: '₦',
        decimalDigits: 2,
        rateFromUsd: 1600.0),
    AppCurrency(
        code: 'KES',
        name: 'Kenyan Shilling',
        symbol: 'KSh',
        decimalDigits: 2,
        rateFromUsd: 129.0),
    AppCurrency(
        code: 'GHS',
        name: 'Ghanaian Cedi',
        symbol: 'GH₵',
        decimalDigits: 2,
        rateFromUsd: 15.5),
    AppCurrency(
        code: 'MAD',
        name: 'Moroccan Dirham',
        symbol: 'MAD',
        decimalDigits: 2,
        rateFromUsd: 9.9),
    AppCurrency(
        code: 'TND',
        name: 'Tunisian Dinar',
        symbol: 'DT',
        decimalDigits: 3,
        rateFromUsd: 3.1),
    AppCurrency(
        code: 'BRL',
        name: 'Brazilian Real',
        symbol: 'R\$',
        decimalDigits: 2,
        rateFromUsd: 5.5),
    AppCurrency(
        code: 'MXN',
        name: 'Mexican Peso',
        symbol: 'Mex\$',
        decimalDigits: 2,
        rateFromUsd: 17.2),
    AppCurrency(
        code: 'ARS',
        name: 'Argentine Peso',
        symbol: '\$',
        decimalDigits: 2,
        rateFromUsd: 960.0),
    AppCurrency(
        code: 'CLP',
        name: 'Chilean Peso',
        symbol: '\$',
        decimalDigits: 0,
        rateFromUsd: 950.0),
    AppCurrency(
        code: 'COP',
        name: 'Colombian Peso',
        symbol: '\$',
        decimalDigits: 0,
        rateFromUsd: 4100.0),
    AppCurrency(
        code: 'PEN',
        name: 'Peruvian Sol',
        symbol: 'S/',
        decimalDigits: 2,
        rateFromUsd: 3.75),
    AppCurrency(
        code: 'KRW',
        name: 'South Korean Won',
        symbol: '₩',
        decimalDigits: 0,
        rateFromUsd: 1370.0),
    AppCurrency(
        code: 'TWD',
        name: 'New Taiwan Dollar',
        symbol: 'NT\$',
        decimalDigits: 2,
        rateFromUsd: 32.2),
    AppCurrency(
        code: 'THB',
        name: 'Thai Baht',
        symbol: '฿',
        decimalDigits: 2,
        rateFromUsd: 35.5),
    AppCurrency(
        code: 'MYR',
        name: 'Malaysian Ringgit',
        symbol: 'RM',
        decimalDigits: 2,
        rateFromUsd: 4.7),
    AppCurrency(
        code: 'IDR',
        name: 'Indonesian Rupiah',
        symbol: 'Rp',
        decimalDigits: 0,
        rateFromUsd: 16200.0),
    AppCurrency(
        code: 'PHP',
        name: 'Philippine Peso',
        symbol: '₱',
        decimalDigits: 2,
        rateFromUsd: 58.0),
    AppCurrency(
        code: 'VND',
        name: 'Vietnamese Dong',
        symbol: '₫',
        decimalDigits: 0,
        rateFromUsd: 25400.0),
  ];
}
