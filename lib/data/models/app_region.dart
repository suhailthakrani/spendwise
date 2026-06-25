class AppRegion {
  const AppRegion({
    required this.code,
    required this.name,
    required this.defaultCurrencyCode,
    required this.locale,
  });

  final String code;
  final String name;
  final String defaultCurrencyCode;
  final String locale;

  static const us = AppRegion(
    code: 'US',
    name: 'United States',
    defaultCurrencyCode: 'USD',
    locale: 'en_US',
  );

  static const pk = AppRegion(
    code: 'PK',
    name: 'Pakistan',
    defaultCurrencyCode: 'PKR',
    locale: 'en_PK',
  );

  static const in_ = AppRegion(
    code: 'IN',
    name: 'India',
    defaultCurrencyCode: 'INR',
    locale: 'en_IN',
  );

  static const eu = AppRegion(
    code: 'EU',
    name: 'Europe',
    defaultCurrencyCode: 'EUR',
    locale: 'en_DE',
  );

  static const ae = AppRegion(
    code: 'AE',
    name: 'United Arab Emirates',
    defaultCurrencyCode: 'AED',
    locale: 'en_AE',
  );

  static const List<AppRegion> all = [us, pk, in_, eu, ae];

  static AppRegion byCode(String code) {
    return all.firstWhere(
      (r) => r.code == code,
      orElse: () => us,
    );
  }
}
