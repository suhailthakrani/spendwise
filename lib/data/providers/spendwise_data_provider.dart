import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/currency_converter.dart';
import '../../core/utils/currency_formatter.dart';
import '../models/app_currency.dart';
import '../models/app_region.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/dashboard_stats.dart';
import '../models/expense.dart';
import '../models/monthly_summary.dart';
import '../models/payment_method.dart';
import '../models/recurring_expense.dart';
import '../models/user_preferences.dart';
import '../models/user_profile.dart';

/// Static data source for UI design. Replace with repository + Riverpod later.
class SpendWiseDataProvider extends ChangeNotifier {
  SpendWiseDataProvider._();

  static final SpendWiseDataProvider instance = SpendWiseDataProvider._();

  static const _uuid = Uuid();
  /// Mock amounts are stored in USD; UI converts to [displayCurrencyCode].
  static const String storageCurrency = 'USD';
  final DateTime _now = DateTime(2026, 6, 25);

  UserPreferences _preferences = UserPreferences.defaults();
  late final UserProfile _profile = _buildProfile();
  late final List<ExpenseCategory> _categories = _buildCategories();
  late final List<Expense> _expenses = _buildExpenses();
  late final List<Budget> _budgets = _buildBudgets();
  late final List<RecurringExpense> _recurring = _buildRecurring();
  late final List<MonthlySummary> _monthlySummaries = _buildMonthlySummaries();

  UserPreferences get preferences => _preferences;
  UserProfile get profile => _profile;
  String get displayCurrencyCode => _preferences.currencyCode;
  AppCurrency get displayCurrency => AppCurrency.byCode(displayCurrencyCode);
  AppRegion get region => AppRegion.byCode(_preferences.regionCode);

  List<ExpenseCategory> get categories => List.unmodifiable(_categories);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Budget> get budgets => List.unmodifiable(_budgets);
  List<RecurringExpense> get recurringExpenses => List.unmodifiable(_recurring);
  List<MonthlySummary> get monthlySummaries => List.unmodifiable(_monthlySummaries);

  void setThemeMode(ThemeMode mode) {
    if (_preferences.themeMode == mode) return;
    _preferences = _preferences.copyWith(themeMode: mode);
    notifyListeners();
  }

  void setRegion(String regionCode) {
    if (_preferences.regionCode == regionCode) return;
    final region = AppRegion.byCode(regionCode);
    _preferences = _preferences.copyWith(
      regionCode: regionCode,
      currencyCode: region.defaultCurrencyCode,
    );
    notifyListeners();
  }

  void setCurrency(String currencyCode) {
    if (_preferences.currencyCode == currencyCode) return;
    _preferences = _preferences.copyWith(currencyCode: currencyCode);
    notifyListeners();
  }

  double toDisplayAmount(double amount) {
    return CurrencyConverter.convert(
      amount: amount,
      fromCurrencyCode: storageCurrency,
      toCurrencyCode: displayCurrencyCode,
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

  /// Formats a value already expressed in the user's selected currency.
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

  ExpenseCategory? categoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Expense? expenseById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Budget? budgetById(String id) {
    try {
      return _budgets.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Expense> expensesForCategory(String categoryId) =>
      _expenses.where((e) => e.categoryId == categoryId).toList();

  List<Expense> searchExpenses({
    String query = '',
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    ExpenseSortBy sortBy = ExpenseSortBy.dateDesc,
  }) {
    var results = _expenses.toList();

    if (query.isNotEmpty) {
      final lower = query.toLowerCase();
      results = results
          .where((e) => e.note.toLowerCase().contains(lower))
          .toList();
    }

    if (categoryId != null) {
      results = results.where((e) => e.categoryId == categoryId).toList();
    }

    if (startDate != null) {
      results = results.where((e) => !e.date.isBefore(startDate)).toList();
    }

    if (endDate != null) {
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      results = results.where((e) => !e.date.isAfter(end)).toList();
    }

    switch (sortBy) {
      case ExpenseSortBy.dateDesc:
        results.sort((a, b) => b.date.compareTo(a.date));
      case ExpenseSortBy.dateAsc:
        results.sort((a, b) => a.date.compareTo(b.date));
      case ExpenseSortBy.amountDesc:
        results.sort(
          (a, b) => toDisplayAmount(b.amount).compareTo(toDisplayAmount(a.amount)),
        );
      case ExpenseSortBy.amountAsc:
        results.sort(
          (a, b) => toDisplayAmount(a.amount).compareTo(toDisplayAmount(b.amount)),
        );
    }

    return results;
  }

  DashboardStats get dashboardStats {
    final today = DateTime(_now.year, _now.month, _now.day);
    final monthStart = DateTime(_now.year, _now.month, 1);

    final todayExpenses = _expenses.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return d == today;
    });

    final monthExpenses = _expenses.where((e) => !e.date.isBefore(monthStart));

    final totalToday = todayExpenses.fold<double>(
      0,
      (s, e) => s + toDisplayAmount(e.amount),
    );
    final totalMonth = monthExpenses.fold<double>(
      0,
      (s, e) => s + toDisplayAmount(e.amount),
    );

    final categoryTotals = <String, double>{};
    for (final e in monthExpenses) {
      final converted = toDisplayAmount(e.amount);
      categoryTotals[e.categoryId] =
          (categoryTotals[e.categoryId] ?? 0) + converted;
    }

    final categorySpending = categoryTotals.entries
        .map((e) => CategorySpending(
              categoryId: e.key,
              amount: e.value,
              percentage: totalMonth > 0 ? (e.value / totalMonth) * 100 : 0,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final sorted = List<Expense>.from(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final monthlyBudget = toDisplayAmount(_budgets.first.limit);

    return DashboardStats(
      totalSpentToday: totalToday,
      totalSpentThisMonth: totalMonth,
      monthlyBudget: monthlyBudget,
      categorySpending: categorySpending,
      recentExpenseIds: sorted.take(5).map((e) => e.id).toList(),
    );
  }

  MonthlySummary get currentMonthSummary {
    final raw = _monthlySummaries.first;
    return _convertSummary(raw);
  }

  MonthlySummary summaryAt(int index) => _convertSummary(_monthlySummaries[index]);

  MonthlySummary _convertSummary(MonthlySummary raw) {
    final breakdown = <String, double>{};
    for (final entry in raw.categoryBreakdown.entries) {
      breakdown[entry.key] = toDisplayAmount(entry.value);
    }
    return MonthlySummary(
      month: raw.month,
      year: raw.year,
      totalIncome: toDisplayAmount(raw.totalIncome),
      totalExpenses: toDisplayAmount(raw.totalExpenses),
      categoryBreakdown: breakdown,
    );
  }

  List<double> get monthlyTrend {
    return _monthlySummaries.reversed
        .map((m) => toDisplayAmount(m.totalExpenses))
        .toList();
  }

  List<String> get monthlyTrendLabels {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return _monthlySummaries.reversed
        .map((m) => months[m.month - 1])
        .toList();
  }

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

  UserProfile _buildProfile() => UserProfile(
        id: _uuid.v4(),
        name: 'Alex Morgan',
        email: 'alex.morgan@evenlogix.com',
        memberSince: DateTime(2025, 3, 15),
      );

  List<ExpenseCategory> _buildCategories() => [
        const ExpenseCategory(
          id: 'cat_food',
          name: 'Food',
          iconName: 'restaurant',
          color: Color(0xFF10B981),
          budgetLimit: 500,
        ),
        const ExpenseCategory(
          id: 'cat_transport',
          name: 'Transport',
          iconName: 'directions_car',
          color: Color(0xFF3B82F6),
          budgetLimit: 300,
        ),
        const ExpenseCategory(
          id: 'cat_shopping',
          name: 'Shopping',
          iconName: 'shopping_bag',
          color: Color(0xFFEC4899),
          budgetLimit: 400,
        ),
        const ExpenseCategory(
          id: 'cat_bills',
          name: 'Bills',
          iconName: 'receipt_long',
          color: Color(0xFFF59E0B),
          budgetLimit: 600,
        ),
        const ExpenseCategory(
          id: 'cat_entertainment',
          name: 'Entertainment',
          iconName: 'movie',
          color: Color(0xFF8B5CF6),
          budgetLimit: 200,
        ),
        const ExpenseCategory(
          id: 'cat_health',
          name: 'Health',
          iconName: 'favorite',
          color: Color(0xFFEF4444),
          isCustom: true,
          budgetLimit: 150,
        ),
        const ExpenseCategory(
          id: 'cat_education',
          name: 'Education',
          iconName: 'school',
          color: Color(0xFF06B6D4),
          isCustom: true,
        ),
      ];

  List<Expense> _buildExpenses() {
    final expenses = <Expense>[
      Expense(
        id: _uuid.v4(),
        amount: 45.99,
        categoryId: 'cat_food',
        note: 'Grocery shopping at Whole Foods',
        date: _now.subtract(const Duration(hours: 2)),
        paymentMethod: PaymentMethod.card,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 12.50,
        categoryId: 'cat_food',
        note: 'Biryani lunch — Karachi',
        date: _now.subtract(const Duration(hours: 5)),
        paymentMethod: PaymentMethod.cash,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 4.00,
        categoryId: 'cat_transport',
        note: 'Auto rickshaw — Mumbai',
        date: _now.subtract(const Duration(hours: 8)),
        paymentMethod: PaymentMethod.cash,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 89.00,
        categoryId: 'cat_shopping',
        note: 'New running shoes',
        date: _now.subtract(const Duration(days: 1)),
        paymentMethod: PaymentMethod.card,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 15.00,
        categoryId: 'cat_transport',
        note: 'Dubai Metro + taxi',
        date: _now.subtract(const Duration(days: 1, hours: 4)),
        paymentMethod: PaymentMethod.digitalWallet,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 120.00,
        categoryId: 'cat_bills',
        note: 'Electricity bill',
        date: _now.subtract(const Duration(days: 2)),
        paymentMethod: PaymentMethod.bankTransfer,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 38.00,
        categoryId: 'cat_entertainment',
        note: 'Museum tickets — Berlin',
        date: _now.subtract(const Duration(days: 3)),
        paymentMethod: PaymentMethod.card,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 8.75,
        categoryId: 'cat_food',
        note: 'Morning coffee',
        date: _now.subtract(const Duration(days: 3, hours: 4)),
        paymentMethod: PaymentMethod.cash,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 1500.00,
        categoryId: 'cat_bills',
        note: 'Monthly rent',
        date: DateTime(_now.year, _now.month, 1),
        paymentMethod: PaymentMethod.bankTransfer,
        isRecurring: true,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 45.00,
        categoryId: 'cat_bills',
        note: 'Utility bills — Islamabad',
        date: DateTime(_now.year, _now.month, 3),
        paymentMethod: PaymentMethod.bankTransfer,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 59.99,
        categoryId: 'cat_bills',
        note: 'Internet subscription',
        date: DateTime(_now.year, _now.month, 5),
        paymentMethod: PaymentMethod.card,
        isRecurring: true,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 24.99,
        categoryId: 'cat_entertainment',
        note: 'Netflix subscription',
        date: DateTime(_now.year, _now.month, 10),
        paymentMethod: PaymentMethod.card,
        isRecurring: true,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 30.00,
        categoryId: 'cat_health',
        note: 'Pharmacy — vitamins',
        date: _now.subtract(const Duration(days: 5)),
        paymentMethod: PaymentMethod.card,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 42.30,
        categoryId: 'cat_food',
        note: 'Dinner with friends',
        date: _now.subtract(const Duration(days: 6)),
        paymentMethod: PaymentMethod.card,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 18.00,
        categoryId: 'cat_transport',
        note: 'Gas station fill-up',
        date: _now.subtract(const Duration(days: 7)),
        paymentMethod: PaymentMethod.cash,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 199.00,
        categoryId: 'cat_education',
        note: 'Online course subscription',
        date: _now.subtract(const Duration(days: 10)),
        paymentMethod: PaymentMethod.card,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 75.00,
        categoryId: 'cat_shopping',
        note: 'Dubai Mall — home essentials',
        date: _now.subtract(const Duration(days: 12)),
        paymentMethod: PaymentMethod.card,
      ),
      Expense(
        id: _uuid.v4(),
        amount: 32.00,
        categoryId: 'cat_food',
        note: 'Lunch at cafe',
        date: _now.subtract(const Duration(days: 14)),
        paymentMethod: PaymentMethod.digitalWallet,
      ),
    ];

    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  List<Budget> _buildBudgets() => const [
        Budget(
          id: 'budget_monthly',
          name: 'Monthly Budget',
          limit: 2500,
          spent: 2100,
        ),
        Budget(
          id: 'budget_food',
          name: 'Food',
          limit: 500,
          spent: 180,
          categoryId: 'cat_food',
        ),
        Budget(
          id: 'budget_transport',
          name: 'Transport',
          limit: 300,
          spent: 95,
          categoryId: 'cat_transport',
        ),
        Budget(
          id: 'budget_shopping',
          name: 'Shopping',
          limit: 400,
          spent: 364,
          categoryId: 'cat_shopping',
        ),
        Budget(
          id: 'budget_entertainment',
          name: 'Entertainment',
          limit: 200,
          spent: 138,
          categoryId: 'cat_entertainment',
        ),
      ];

  List<RecurringExpense> _buildRecurring() => [
        RecurringExpense(
          id: _uuid.v4(),
          title: 'Rent',
          amount: 1500,
          categoryId: 'cat_bills',
          frequency: RecurrenceFrequency.monthly,
          nextDueDate: DateTime(_now.year, _now.month + 1, 1),
          paymentMethod: PaymentMethod.bankTransfer,
        ),
        RecurringExpense(
          id: _uuid.v4(),
          title: 'Internet',
          amount: 59.99,
          categoryId: 'cat_bills',
          frequency: RecurrenceFrequency.monthly,
          nextDueDate: DateTime(_now.year, _now.month + 1, 5),
          paymentMethod: PaymentMethod.card,
        ),
        RecurringExpense(
          id: _uuid.v4(),
          title: 'Netflix',
          amount: 24.99,
          categoryId: 'cat_entertainment',
          frequency: RecurrenceFrequency.monthly,
          nextDueDate: DateTime(_now.year, _now.month + 1, 10),
          paymentMethod: PaymentMethod.card,
        ),
        RecurringExpense(
          id: _uuid.v4(),
          title: 'Gym Membership',
          amount: 18.00,
          categoryId: 'cat_health',
          frequency: RecurrenceFrequency.monthly,
          nextDueDate: DateTime(_now.year, _now.month + 1, 15),
          paymentMethod: PaymentMethod.card,
        ),
      ];

  List<MonthlySummary> _buildMonthlySummaries() => const [
        MonthlySummary(
          month: 6,
          year: 2026,
          totalIncome: 5200,
          totalExpenses: 2100,
          categoryBreakdown: {
            'cat_bills': 1679.99,
            'cat_shopping': 364.50,
            'cat_food': 126.04,
            'cat_health': 65.00,
            'cat_entertainment': 59.99,
            'cat_transport': 95.00,
            'cat_education': 199.00,
          },
        ),
        MonthlySummary(
          month: 5,
          year: 2026,
          totalIncome: 5200,
          totalExpenses: 2103.45,
          categoryBreakdown: {
            'cat_bills': 1580.00,
            'cat_food': 312.50,
            'cat_shopping': 89.95,
            'cat_transport': 78.00,
            'cat_entertainment': 43.00,
          },
        ),
        MonthlySummary(
          month: 4,
          year: 2026,
          totalIncome: 5200,
          totalExpenses: 1950.20,
          categoryBreakdown: {
            'cat_bills': 1580.00,
            'cat_food': 245.20,
            'cat_transport': 65.00,
            'cat_shopping': 60.00,
          },
        ),
        MonthlySummary(
          month: 3,
          year: 2026,
          totalIncome: 5200,
          totalExpenses: 2234.80,
          categoryBreakdown: {
            'cat_bills': 1580.00,
            'cat_food': 389.80,
            'cat_shopping': 165.00,
            'cat_entertainment': 100.00,
          },
        ),
        MonthlySummary(
          month: 2,
          year: 2026,
          totalIncome: 5200,
          totalExpenses: 1789.30,
          categoryBreakdown: {
            'cat_bills': 1580.00,
            'cat_food': 109.30,
            'cat_transport': 100.00,
          },
        ),
        MonthlySummary(
          month: 1,
          year: 2026,
          totalIncome: 5200,
          totalExpenses: 2012.15,
          categoryBreakdown: {
            'cat_bills': 1580.00,
            'cat_food': 232.15,
            'cat_shopping': 200.00,
          },
        ),
      ];
}

enum ExpenseSortBy {
  dateDesc('Newest first'),
  dateAsc('Oldest first'),
  amountDesc('Highest amount'),
  amountAsc('Lowest amount');

  const ExpenseSortBy(this.label);
  final String label;
}
