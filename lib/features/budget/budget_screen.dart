import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../data/models/category.dart';
import '../../data/models/recurring_expense.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final recurringAsync = ref.watch(recurringExpensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencyDisplayProvider);
    final currencyCode = ref.watch(displayCurrencyCodeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              currencyCode,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (rawBudgets) {
          if (rawBudgets.isEmpty) {
            return const EmptyState(
              iconAsset: AppIcons.budget,
              title: 'No budgets yet',
              subtitle: 'Tap + to create your first budget.',
            );
          }

          final categories = categoriesAsync.valueOrNull ?? [];
          final recurring = recurringAsync.valueOrNull ?? [];
          final monthlyBudget = currency.budgetInDisplay(rawBudgets.first);
          final categoryBudgets =
              rawBudgets.skip(1).map(currency.budgetInDisplay).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: monthlyBudget.isOverBudget
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.error.withValues(alpha: 0.15),
                              AppColors.error.withValues(alpha: 0.08),
                            ],
                          )
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0D9488),
                              Color(0xFF0F766E),
                              Color(0xFF115E59),
                            ],
                            stops: [0.0, 0.55, 1.0],
                          ),
                    boxShadow: monthlyBudget.isOverBudget
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                    border: monthlyBudget.isOverBudget
                        ? Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          )
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.push(
                        '/budget/${rawBudgets.first.id}/edit',
                      ),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: monthlyBudget.isOverBudget
                                        ? AppColors.error.withValues(alpha: 0.15)
                                        : Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: AppIcon(
                                    monthlyBudget.isOverBudget
                                        ? AppIcons.warning
                                        : AppIcons.wallet,
                                    color: monthlyBudget.isOverBudget
                                        ? AppColors.error
                                        : Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Monthly Budget',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: monthlyBudget.isOverBudget
                                          ? null
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                AppIcon(
                                  AppIcons.edit,
                                  size: 18,
                                  color: monthlyBudget.isOverBudget
                                      ? AppColors.textSecondaryLight
                                      : Colors.white.withValues(alpha: 0.8),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              currency.formatDisplay(monthlyBudget.spent),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: monthlyBudget.isOverBudget
                                    ? null
                                    : Colors.white,
                              ),
                            ),
                            Text(
                              'of ${currency.formatDisplay(monthlyBudget.limit)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: monthlyBudget.isOverBudget
                                    ? null
                                    : Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: monthlyBudget.progress,
                                minHeight: 8,
                                backgroundColor: monthlyBudget.isOverBudget
                                    ? theme.brightness == Brightness.dark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.black.withValues(alpha: 0.06)
                                    : Colors.white.withValues(alpha: 0.2),
                                color: monthlyBudget.isOverBudget
                                    ? AppColors.error
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              monthlyBudget.isOverBudget
                                  ? 'Over budget by ${currency.formatDisplay(monthlyBudget.spent - monthlyBudget.limit)}'
                                  : '${currency.formatDisplay(monthlyBudget.remaining)} remaining',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: monthlyBudget.isOverBudget
                                    ? AppColors.error
                                    : Colors.white.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
                          ? categoryById(categories, b.categoryId!)
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
                                      asset:
                                          AppIcons.categoryIcon(cat.iconName),
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
                                  const AppIcon(
                                    AppIcons.chevronRight,
                                    size: 18,
                                  ),
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
              ...recurring.map(
                (r) => _RecurringTile(
                  recurring: r,
                  category: categoryById(categories, r.categoryId),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addBudget),
        child: const AppIcon(
          AppIcons.add,
          size: 24,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _RecurringTile extends ConsumerWidget {
  const _RecurringTile({
    required this.recurring,
    required this.category,
  });

  final RecurringExpense recurring;
  final ExpenseCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyDisplayProvider);
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
        currency.formatDisplay(recurring.amount),
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
