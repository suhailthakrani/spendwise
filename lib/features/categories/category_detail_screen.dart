import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final expensesAsync = ref.watch(categoryExpensesProvider(categoryId));
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);

    final category = categoryById(
      categoriesAsync.valueOrNull ?? [],
      categoryId,
    );

    if (categoriesAsync.isLoading && category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          iconAsset: AppIcons.error,
          title: 'Category not found',
        ),
      );
    }

    return expensesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(category.name)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(category.name)),
        body: Center(child: Text('Error: $error')),
      ),
      data: (expenses) {
        final total = expenses.fold<double>(
          0,
          (s, e) => s + currency.toDisplayAmount(e.amount),
        );
        final budgetLimit = category.budgetLimit != null
            ? currency.toDisplayAmount(category.budgetLimit!)
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
                          currency.formatDisplay(total),
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
                    onTap: () => context.push('/expenses/${expense.id}'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
