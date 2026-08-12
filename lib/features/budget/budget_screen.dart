import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../core/widgets/goal_progress_banner.dart';
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
                color: AppColors.secondaryText(context),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Saving goals',
            onPressed: () => context.push(AppRoutes.goals),
            icon: const AppIcon(AppIcons.savings, size: 22),
          ),
          IconButton(
            tooltip: 'Add budget',
            onPressed: () => context.push(AppRoutes.addBudget),
            icon: const AppIcon(AppIcons.add, size: 22),
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (rawBudgets) {
          final categories = categoriesAsync.valueOrNull ?? [];
          final recurring = recurringAsync.valueOrNull ?? [];
          final monthlyRaw =
              rawBudgets.where((b) => b.categoryId == null).firstOrNull;
          final categoryRaws =
              rawBudgets.where((b) => b.categoryId != null).toList();
          final monthlyBudget = monthlyRaw != null
              ? currency.budgetInDisplay(monthlyRaw)
              : null;
          final categoryBudgets =
              categoryRaws.map(currency.budgetInDisplay).toList();

          if (rawBudgets.isEmpty) {
            return ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
              children: [
                const GoalProgressBanner(),
                const SizedBox(height: 48),
                EmptyState(
                  iconAsset: AppIcons.budget,
                  title: 'No budgets yet',
                  subtitle: 'Create a monthly budget to track your spending.',
                  actionLabel: 'Add budget',
                  onAction: () => context.push(AppRoutes.addBudget),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
            children: [
              const GoalProgressBanner(),
              if (monthlyBudget != null && monthlyRaw != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    8,
                    AppSpacing.page,
                    0,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      gradient: monthlyBudget.isOverBudget
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.error.withValues(alpha: 0.14),
                                AppColors.error.withValues(alpha: 0.06),
                              ],
                            )
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF0F766E),
                                Color(0xFF0D9488),
                                Color(0xFF0F766E),
                              ],
                              stops: [0.0, 0.55, 1.0],
                            ),
                      boxShadow: monthlyBudget.isOverBudget
                          ? null
                          : [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.22),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                      border: monthlyBudget.isOverBudget
                          ? Border.all(
                              color: AppColors.error.withValues(alpha: 0.22),
                            )
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push(
                          '/budget/${monthlyRaw.id}/edit',
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: monthlyBudget.isOverBudget
                                          ? AppColors.error
                                              .withValues(alpha: 0.14)
                                          : Colors.white
                                              .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(AppRadii.md),
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
                                      'Monthly budget',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
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
                                        ? AppColors.secondaryText(context)
                                        : Colors.white.withValues(alpha: 0.8),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                        
                              Text(
                                currency.formatInUserCurrency(
                                  monthlyBudget.isOverBudget
                                      ? monthlyBudget.spent -
                                          monthlyBudget.limit
                                      : monthlyBudget.remaining
                                          .clamp(0, double.infinity),
                                ),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  color: monthlyBudget.isOverBudget
                                      ? AppColors.error
                                      : Colors.white,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),                              
                              const SizedBox(height: 18),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.full),
                                child: LinearProgressIndicator(
                                  value: monthlyBudget.progress,
                                  minHeight: 8,
                                  backgroundColor: monthlyBudget.isOverBudget
                                      ? AppColors.softFill(context)
                                      : Colors.white.withValues(alpha: 0.2),
                                  color: monthlyBudget.isOverBudget
                                      ? AppColors.error
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${currency.formatInUserCurrency(monthlyBudget.spent)} spent of ${currency.formatInUserCurrency(monthlyBudget.limit)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: monthlyBudget.isOverBudget
                                      ? AppColors.secondaryText(context)
                                      : Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    8,
                    AppSpacing.page,
                    0,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: const AppIconBox(
                        asset: AppIcons.wallet,
                        color: AppColors.primary,
                        size: 42,
                        iconSize: 20,
                      ),
                      title: const Text('Set a monthly budget'),
                      subtitle: const Text('Track how much you can spend'),
                      trailing: const AppIcon(AppIcons.add, size: 20),
                      onTap: () => context.push(AppRoutes.addBudget),
                    ),
                  ),
                ),
              SectionHeader(
                title: 'Category budgets',
                actionLabel: 'Add',
                onActionTap: () => context.push(AppRoutes.addBudget),
              ),
              if (categoryBudgets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No category budgets yet. Add one to cap spending by category.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: Card(
                    child: Column(
                      children: List.generate(categoryBudgets.length, (index) {
                        final b = categoryBudgets[index];
                        final raw = categoryRaws[index];
                        final cat = b.categoryId != null
                            ? categoryById(categories, b.categoryId!)
                            : null;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () =>
                                  context.push('/budget/${raw.id}/edit'),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    if (cat != null)
                                      AppIconBox(
                                        asset: AppIcons.categoryIcon(
                                          cat.iconName,
                                        ),
                                        color: cat.color,
                                        size: 42,
                                        iconSize: 20,
                                      )
                                    else
                                      const AppIconBox(
                                        asset: AppIcons.budget,
                                        color: AppColors.primary,
                                        size: 42,
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
                                    AppIcon(
                                      AppIcons.chevronRight,
                                      size: 18,
                                      color: AppColors.tertiaryText(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < categoryBudgets.length - 1)
                              Divider(
                                height: 1,
                                indent: 70,
                                color: AppColors.border(context),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              if (recurring.isNotEmpty) ...[
                const SectionHeader(title: 'Recurring'),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < recurring.length; i++) ...[
                          _RecurringTile(
                            recurring: recurring[i],
                            category: categoryById(
                              categories,
                              recurring[i].categoryId,
                            ),
                          ),
                          if (i < recurring.length - 1)
                            Divider(
                              height: 1,
                              indent: 70,
                              color: AppColors.border(context),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              const _GoalsShortcut(),
            ],
          );
        },
      ),
    );
  }
}

class _GoalsShortcut extends ConsumerWidget {
  const _GoalsShortcut();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pace = ref.watch(monthlyGoalsPaceProvider);
    if (pace.activeCount > 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        20,
        AppSpacing.page,
        0,
      ),
      child: Card(
        child: ListTile(
          leading: const AppIconBox(
            asset: AppIcons.savings,
            color: AppColors.accent,
            size: 42,
            iconSize: 20,
          ),
          title: const Text('Set a saving goal'),
          subtitle: const Text('Track progress toward a wishlist or fund'),
          trailing: const AppIcon(AppIcons.chevronRight, size: 18),
          onTap: () => context.push(AppRoutes.goals),
        ),
      ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          AppIconBox(
            asset: AppIcons.repeat,
            color: category?.color ?? AppColors.primary,
            size: 42,
            iconSize: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recurring.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$frequencyLabel · Due ${DateFormatter.short(recurring.nextDueDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
          Text(
            currency.formatDisplay(recurring.amount),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
