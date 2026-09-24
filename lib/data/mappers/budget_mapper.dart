import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/budget.dart';
import '../models/budget_period_type.dart';

abstract final class BudgetMapper {
  static Budget fromRow(BudgetRow row, {required double spent}) {
    return Budget(
      id: row.id,
      name: row.name,
      limit: row.limitAmount,
      spent: spent,
      categoryId: row.categoryId,
      isMonthly: row.isMonthly,
      year: row.year,
      month: row.month,
      periodType: BudgetPeriodType.fromDb(row.periodType),
      startDate: row.startDate,
      endDate: row.endDate,
      rolloverEnabled: row.rolloverEnabled,
      rolloverAmount: row.rolloverAmount,
      isSpendingLimit: row.isSpendingLimit,
    );
  }

  static BudgetsCompanion toCompanion({
    required String id,
    required String userId,
    required String name,
    required double limit,
    required int year,
    required int month,
    String? categoryId,
    bool isMonthly = true,
    BudgetPeriodType periodType = BudgetPeriodType.monthly,
    DateTime? startDate,
    DateTime? endDate,
    bool rolloverEnabled = false,
    double rolloverAmount = 0,
    bool isSpendingLimit = false,
  }) {
    return BudgetsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      limitAmount: Value(limit),
      categoryId: Value(categoryId),
      isMonthly: Value(isMonthly),
      year: Value(year),
      month: Value(month),
      periodType: Value(periodType.name),
      startDate: Value(startDate),
      endDate: Value(endDate),
      rolloverEnabled: Value(rolloverEnabled),
      rolloverAmount: Value(rolloverAmount),
      isSpendingLimit: Value(isSpendingLimit),
    );
  }
}
