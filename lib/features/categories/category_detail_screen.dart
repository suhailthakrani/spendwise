import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../data/providers/spendwise_data_provider.dart';

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;
    final category = provider.categoryById(categoryId);
    final theme = Theme.of(context);

    if (category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          iconAsset: AppIcons.error,
          title: 'Category not found',
        ),
      );
    }

    final expenses = provider.expensesForCategory(categoryId);
    final total = expenses.fold<double>(
      0,
      (s, e) => s + provider.toDisplayAmount(e.amount),
    );
    final budgetLimit = category.budgetLimit != null
        ? provider.toDisplayAmount(category.budgetLimit!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          if (category.isCustom)
            IconButton(
              icon: const AppIcon(AppIcons.edit, size: 22),
              onPressed: () {},
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AppIconBox(
                      asset: AppIcons.categoryIcon(category.iconName),
                      color: category.color,
                      size: 64,
                      iconSize: 32,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.formatDisplay(total),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Total spent · ${expenses.length} transactions',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (budgetLimit != null) ...[
                      const SizedBox(height: 16),
                      BudgetProgressBar(
                        label: 'Budget',
                        spent: total,
                        limit: budgetLimit,
                        color: category.color,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SectionHeader(title: 'Transactions'),
          if (expenses.isEmpty)
            const EmptyState(
              iconAsset: AppIcons.receiptEmpty,
              title: 'No transactions in this category',
            )
          else
            ...expenses.map(
              (expense) => ExpenseTile(
                expense: expense,
                category: category,
                onTap: () {},
              ),
            ),
        ],
      ),
    );
  }
}
