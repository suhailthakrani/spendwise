import '../../data/models/app_currency.dart';

abstract final class CurrencyConverter {
  static double toUsd(double amount, String fromCurrencyCode) {
    final currency = AppCurrency.byCode(fromCurrencyCode);
    return amount / currency.rateFromUsd;
  }

  static double fromUsd(double amountUsd, String toCurrencyCode) {
    final currency = AppCurrency.byCode(toCurrencyCode);
    return amountUsd * currency.rateFromUsd;
  }

  static double convert({
    required double amount,
    required String fromCurrencyCode,
    required String toCurrencyCode,
  }) {
    if (fromCurrencyCode == toCurrencyCode) return amount;
    final usd = toUsd(amount, fromCurrencyCode);
    return fromUsd(usd, toCurrencyCode);
  }
}
