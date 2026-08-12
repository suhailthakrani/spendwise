import 'package:intl/intl.dart';

import '../../data/models/app_currency.dart';
import 'currency_converter.dart';

abstract final class CurrencyFormatter {
  static String format(
    double amount, {
    required String currencyCode,
    String? displayCurrencyCode,
    String? locale,
    bool compact = false,
  }) {
    final targetCode = displayCurrencyCode ?? currencyCode;
    final converted = currencyCode == targetCode
        ? amount
        : CurrencyConverter.convert(
            amount: amount,
            fromCurrencyCode: currencyCode,
            toCurrencyCode: targetCode,
          );

    final currency = AppCurrency.byCode(targetCode);
    final resolvedLocale = locale ?? 'en_US';

    final formatter = compact
        ? NumberFormat.compactCurrency(
            locale: resolvedLocale,
            symbol: currency.symbol,
            decimalDigits: 0,
            name: currency.code,
          )
        : NumberFormat.currency(
            locale: resolvedLocale,
            symbol: '${currency.symbol}\u00A0',
            decimalDigits: currency.decimalDigits,
            name: currency.code,
          );

    return formatter.format(converted).trim();
  }

  static String formatCompact(
    double amount, {
    required String currencyCode,
    String? displayCurrencyCode,
    String? locale,
  }) =>
      format(
        amount,
        currencyCode: currencyCode,
        displayCurrencyCode: displayCurrencyCode,
        locale: locale,
        compact: true,
      );
}
