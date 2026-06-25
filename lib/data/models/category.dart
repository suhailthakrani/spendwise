import 'package:flutter/material.dart';

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
    this.isCustom = false,
    this.budgetLimit,
  });

  final String id;
  final String name;
  final String iconName;
  final Color color;
  final bool isCustom;
  final double? budgetLimit;

  ExpenseCategory copyWith({
    String? id,
    String? name,
    String? iconName,
    Color? color,
    bool? isCustom,
    double? budgetLimit,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
      budgetLimit: budgetLimit ?? this.budgetLimit,
    );
  }
}
