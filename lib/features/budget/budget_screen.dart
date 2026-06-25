import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../data/models/recurring_expense.dart';
import '../../data/providers/spendwise_data_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;
    final rawBudgets = provider.budgets;
    final monthlyBudget = provider.budgetInDisplay(rawBudgets.first);
    final categoryBudgets =
        rawBudgets.skip(1).map(provider.budgetInDisplay).toList();
    final recurring = provider.recurringExpenses;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget · ${provider.displayCurrencyCode}'),
        actions: [
          IconButton(
            icon: const AppIcon(AppIcons.add, size: 22),
            onPressed: () => context.push(AppRoutes.addBudget),
            tooltip: 'Add budget',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Card(
              color: monthlyBudget.isOverBudget
                  ? AppColors.error.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.08),
              child: InkWell(
                onTap: () => context.push(
                  '/budget/${rawBudgets.first.id}/edit',
                ),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppIcon(
                            monthlyBudget.isOverBudget
                                ? AppIcons.warning
                                : AppIcons.wallet,
                            color: monthlyBudget.isOverBudget
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Monthly Budget',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const AppIcon(AppIcons.edit, size: 18),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.formatDisplay(monthlyBudget.spent),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'of ${provider.formatDisplay(monthlyBudget.limit)}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: monthlyBudget.progress,
                          minHeight: 10,
                          backgroundColor: theme.brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                          color: monthlyBudget.isOverBudget
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        monthlyBudget.isOverBudget
                            ? 'Over budget by ${provider.formatDisplay(monthlyBudget.spent - monthlyBudget.limit)}'
                            : '${provider.formatDisplay(monthlyBudget.remaining)} remaining',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: monthlyBudget.isOverBudget
                              ? AppColors.error
                              : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SectionHeader(
            title: 'Category Budgets',
            actionLabel: 'Add',
            onActionTap: () => context.push(AppRoutes.addBudget),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Column(
                children: List.generate(categoryBudgets.length, (index) {
                  final b = categoryBudgets[index];
                  final raw = rawBudgets[index + 1];
                  final cat = b.categoryId != null
                      ? provider.categoryById(b.categoryId!)
                      : null;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () =>
                            context.push('/budget/${raw.id}/edit'),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              if (cat != null)
                                AppIconBox(
                                  asset: AppIcons.categoryIcon(cat.iconName),
                                  color: cat.color,
                                  size: 40,
                                  iconSize: 20,
                                )
                              else
                                const AppIconBox(
                                  asset: AppIcons.budget,
                                  color: AppColors.primary,
                                  size: 40,
                                  iconSize: 20,
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: BudgetProgressBar(
                                  label: b.name,
                                  spent: b.spent,
                                  limit: b.limit,
                                  color: cat?.color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const AppIcon(AppIcons.chevronRight, size: 18),
                            ],
                          ),
                        ),
                      ),
                      if (index < categoryBudgets.length - 1)
                        const Divider(height: 1, indent: 68),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SectionHeader(title: 'Recurring Expenses'),
          ...recurring.map((r) => _RecurringTile(recurring: r)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addBudget),
        icon: const AppIcon(AppIcons.add, size: 22, color: Colors.white),
        label: const Text('Add Budget'),
      ),
    );
  }
}

class _RecurringTile extends StatelessWidget {
  const _RecurringTile({required this.recurring});

  final RecurringExpense recurring;

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;
    final category = provider.categoryById(recurring.categoryId);
    final theme = Theme.of(context);

    final frequencyLabel = switch (recurring.frequency) {
      RecurrenceFrequency.weekly => 'Weekly',
      RecurrenceFrequency.monthly => 'Monthly',
      RecurrenceFrequency.yearly => 'Yearly',
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: AppIconBox(
        asset: AppIcons.repeat,
        color: category?.color ?? AppColors.primary,
      ),
      title: Text(
        recurring.title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '$frequencyLabel · Due ${DateFormatter.short(recurring.nextDueDate)}',
      ),
      trailing: Text(
        provider.formatDisplay(recurring.amount),
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
