import '../../data/models/app_currency.dart';
import '../../data/models/budget.dart';
import '../../data/models/expense.dart';
import 'currency_converter.dart';
import 'currency_formatter.dart';

/// Formats amounts for the user's display currency.
///
/// Storage is always USD. Call sites must pick the right formatter:
/// - [formatDisplay] / [toDisplayAmount]: pass **storage (USD)** amounts
/// - [formatInUserCurrency]: pass amounts **already converted** to display currency
class CurrencyDisplay {
  const CurrencyDisplay(this.displayCurrencyCode);

  static const String storageCurrency = 'USD';

  final String displayCurrencyCode;

  AppCurrency get displayCurrency => AppCurrency.byCode(displayCurrencyCode);

  double toDisplayAmount(double amount) {
    return CurrencyConverter.convert(
      amount: amount,
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

  /// Formats a **USD storage** amount into the user's currency.
  String formatDisplay(double amount, {bool compact = false}) {
    return CurrencyFormatter.format(
      amount,
      currencyCode: storageCurrency,
      displayCurrencyCode: displayCurrencyCode,
      compact: compact,
    );
  }

  /// Formats an amount that is **already** in the user's display currency.
  String formatInUserCurrency(double amount, {bool compact = false}) {
    return CurrencyFormatter.format(
      amount,
      currencyCode: displayCurrencyCode,
      displayCurrencyCode: displayCurrencyCode,
      compact: compact,
    );
  }

  String formatExpense(Expense expense, {bool compact = false}) =>
      formatDisplay(expense.amount, compact: compact);

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
