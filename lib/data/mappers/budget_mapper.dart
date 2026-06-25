import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';
import '../models/budget.dart';

abstract final class BudgetMapper {
  static Budget fromRow(BudgetRow row, {required double spent}) {
    return Budget(
      id: row.id,
      name: row.name,
      limit: row.limitAmount,
      spent: spent,
      categoryId: row.categoryId,
      isMonthly: row.isMonthly,
    );
  }

  static BudgetsCompanion toCompanion({
    required String id,
    required String name,
    required double limit,
    String? categoryId,
    bool isMonthly = true,
  }) {
    return BudgetsCompanion(
      id: Value(id),
      name: Value(name),
      limitAmount: Value(limit),
      categoryId: Value(categoryId),
      isMonthly: Value(isMonthly),
    );
  }
}
