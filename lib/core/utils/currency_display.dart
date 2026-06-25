import '../../data/models/app_currency.dart';
import '../../data/models/budget.dart';
import '../../data/models/expense.dart';
import 'currency_converter.dart';
import 'currency_formatter.dart';

/// Formats amounts stored in [storageCurrency] for the user's display currency.
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

  String formatDisplay(double amount, {bool compact = false}) {
    return CurrencyFormatter.format(
      amount,
      currencyCode: storageCurrency,
      displayCurrencyCode: displayCurrencyCode,
      compact: compact,
    );
  }

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
