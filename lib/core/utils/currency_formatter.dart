import 'package:intl/intl.dart';

import '../../data/models/app_currency.dart';
import 'currency_converter.dart';

abstract final class CurrencyFormatter {
  static String format(
    double amount, {
    required String currencyCode,
    String? displayCurrencyCode,
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
    final formatter = compact
        ? NumberFormat.compactCurrency(
            symbol: currency.symbol,
            decimalDigits: 0,
            name: currency.code,
          )
        : NumberFormat.currency(
            symbol: currency.symbol,
            decimalDigits: currency.decimalDigits,
            name: currency.code,
          );

    return formatter.format(converted);
  }

  static String formatCompact(
    double amount, {
    required String currencyCode,
    String? displayCurrencyCode,
  }) =>
      format(
        amount,
        currencyCode: currencyCode,
        displayCurrencyCode: displayCurrencyCode,
        compact: true,
      );
}
