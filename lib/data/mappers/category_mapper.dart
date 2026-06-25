import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../models/category.dart';

abstract final class CategoryMapper {
  static ExpenseCategory fromRow(CategoryRow row) {
    return ExpenseCategory(
      id: row.id,
      name: row.name,
      iconName: row.iconName,
      color: Color(row.colorValue),
      isCustom: row.isCustom,
      budgetLimit: row.budgetLimit,
    );
  }

  static CategoriesCompanion toCompanion(ExpenseCategory category) {
    return CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
      iconName: Value(category.iconName),
      colorValue: Value(category.color.toARGB32()),
      isCustom: Value(category.isCustom),
      budgetLimit: Value(category.budgetLimit),
    );
  }
}
