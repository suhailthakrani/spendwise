import 'dart:math' as math;

import '../../data/models/app_currency.dart';
import '../../data/models/app_region.dart';
import '../../data/models/budget.dart';
import '../../data/models/expense.dart';
import 'currency_converter.dart';
import 'currency_formatter.dart';

/// Formats amounts for the signed-in user's display currency.
///
/// Storage is always USD. Prefer:
/// - [format] / [toDisplayAmount] for **storage (USD)** amounts
/// - [formatAlreadyConverted] only when the value is already in display currency
class CurrencyDisplay {
  const CurrencyDisplay({
    required this.displayCurrencyCode,
    this.regionCode = 'US',
  });

  static const String storageCurrency = 'USD';

  final String displayCurrencyCode;
  final String regionCode;

  AppCurrency get displayCurrency => AppCurrency.byCode(displayCurrencyCode);
  AppRegion get region => AppRegion.byCode(regionCode);
  String get locale => region.locale;
  int get decimalDigits => displayCurrency.decimalDigits;
  String get symbol => displayCurrency.symbol;

  double toDisplayAmount(double storageUsdAmount) {
    return CurrencyConverter.convert(
      amount: storageUsdAmount,
      fromCurrencyCode: storageCurrency,
      toCurrencyCode: displayCurrencyCode,
    );
  }

  double toStorageAmount(double displayAmount) {
    return CurrencyConverter.convert(
      amount: displayAmount,
      fromCurrencyCode: displayCurrencyCode,
      toCurrencyCode: storageCurrency,
    );
  }

  /// Formats a USD storage amount into the user's currency string.
  String format(double storageUsdAmount, {bool compact = false}) {
    return CurrencyFormatter.format(
      storageUsdAmount,
      currencyCode: storageCurrency,
      displayCurrencyCode: displayCurrencyCode,
      locale: locale,
      compact: compact,
    );
  }

  /// Alias of [format] for existing call sites.
  String formatDisplay(double storageUsdAmount, {bool compact = false}) =>
      format(storageUsdAmount, compact: compact);

  /// Formats an amount that is **already** in the user's display currency.
  String formatAlreadyConverted(double displayAmount, {bool compact = false}) {
    return CurrencyFormatter.format(
      displayAmount,
      currencyCode: displayCurrencyCode,
      displayCurrencyCode: displayCurrencyCode,
      locale: locale,
      compact: compact,
    );
  }

  /// Alias kept for existing UI call sites (already-converted amounts).
  String formatInUserCurrency(double displayAmount, {bool compact = false}) =>
      formatAlreadyConverted(displayAmount, compact: compact);

  /// Plain numeric text for amount TextFields (no symbol / grouping).
  String formatForInput(double storageUsdAmount) {
    final display = toDisplayAmount(storageUsdAmount);
    final factor = math.pow(10, decimalDigits).toDouble();
    final rounded = (display * factor).round() / factor;
    if (decimalDigits <= 0) {
      return rounded.round().toString();
    }
    return rounded.toStringAsFixed(decimalDigits);
  }

  /// Parses amount field text into a display-currency number.
  ///
  /// Accepts optional spaces, commas, and a trailing decimal point while typing.
  double? parseInput(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return null;

    // Strip common currency symbols / letters users may paste.
    text = text
        .replaceAll(symbol, '')
        .replaceAll(displayCurrencyCode, '')
        .replaceAll(RegExp(r'[^\d.,]'), '')
        .replaceAll(',', '')
        .trim();

    if (text.isEmpty || text == '.') return null;

    final value = double.tryParse(text);
    if (value == null || value.isNaN || value.isInfinite) return null;
    if (value < 0) return null;
    return value;
  }

  String get amountInputHint =>
      decimalDigits <= 0 ? '0' : '0.${'0' * decimalDigits}';

  bool get allowsDecimalInput => decimalDigits > 0;

  String formatExpense(Expense expense, {bool compact = false}) =>
      format(expense.amount, compact: compact);

  Budget budgetInDisplay(Budget budget) {
    return Budget(
      id: budget.id,
      name: budget.name,
      limit: toDisplayAmount(budget.limit),
      spent: toDisplayAmount(budget.spent),
      categoryId: budget.categoryId,
      isMonthly: budget.isMonthly,
    );
  }
}
