import '../services/budget_rollover.dart';
import 'budget_period_type.dart';

class Budget {
  const Budget({
    required this.id,
    required this.name,
    required this.limit,
    required this.spent,
    required this.year,
    required this.month,
    this.categoryId,
    this.isMonthly = true,
    this.periodType = BudgetPeriodType.monthly,
    this.startDate,
    this.endDate,
    this.rolloverEnabled = false,
    this.rolloverAmount = 0,
    this.isSpendingLimit = false,
  });

  final String id;
  final String name;
  /// Stored in the app's base currency (USD). Display uses global preference.
  final double limit;
  final double spent;
  final String? categoryId;
  final bool isMonthly;
  final int year;
  final int month;
  final BudgetPeriodType periodType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool rolloverEnabled;
  final double rolloverAmount;
  final bool isSpendingLimit;

  DateTime get period => DateTime(year, month);

  /// Day of month the budget period starts. Defaults to the 1st.
  int get startDay => startDate?.day ?? 1;

  /// Inclusive start of the tracked period.
  DateTime get periodStart =>
      startDate ??
      resolvePeriodStart(
        year: year,
        month: month,
        startDay: startDay,
      );

  /// Inclusive end of the tracked period (day before the next cycle starts).
  ///
  /// Example: start day 15 in September → Sep 15 … Oct 14.
  DateTime get periodEnd =>
      endDate ??
      resolvePeriodEnd(
        year: year,
        month: month,
        startDay: startDay,
      );

  /// Whether [date] falls inside this budget's period window.
  bool isActiveOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(periodStart.year, periodStart.month, periodStart.day);
    final end = DateTime(periodEnd.year, periodEnd.month, periodEnd.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  /// Clamps [startDay] into a valid calendar day for [year]/[month].
  static DateTime resolvePeriodStart({
    required int year,
    required int month,
    int startDay = 1,
  }) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = startDay.clamp(1, lastDay);
    return DateTime(year, month, day);
  }

  /// Day before the next cycle's start (so periods never overlap).
  ///
  /// Start day 1 → last day of [month].
  /// Start day 15 in Sep → Oct 14.
  static DateTime resolvePeriodEnd({
    required int year,
    required int month,
    int startDay = 1,
  }) {
    final nextStart = resolvePeriodStart(
      year: year,
      month: month + 1,
      startDay: startDay,
    );
    return nextStart.subtract(const Duration(days: 1));
  }

  double get effectiveLimit => BudgetRollover.effectiveLimit(
        limit: limit,
        rolloverAmount: rolloverAmount,
      );

  double get remaining => effectiveLimit - spent;
  double get progress =>
      effectiveLimit > 0 ? (spent / effectiveLimit).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spent > effectiveLimit;

  Budget copyWith({
    String? id,
    String? name,
    double? limit,
    double? spent,
    String? categoryId,
    bool clearCategoryId = false,
    bool? isMonthly,
    int? year,
    int? month,
    BudgetPeriodType? periodType,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? rolloverEnabled,
    double? rolloverAmount,
    bool? isSpendingLimit,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      isMonthly: isMonthly ?? this.isMonthly,
      year: year ?? this.year,
      month: month ?? this.month,
      periodType: periodType ?? this.periodType,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      rolloverEnabled: rolloverEnabled ?? this.rolloverEnabled,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
      isSpendingLimit: isSpendingLimit ?? this.isSpendingLimit,
    );
  }
}
