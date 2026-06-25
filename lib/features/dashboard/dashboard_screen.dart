import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/chart_widgets.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../data/providers/spendwise_data_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;
    final stats = provider.dashboardStats;
    final theme = Theme.of(context);
    final currency = provider.displayCurrencyCode;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SpendWise',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Track every penny wisely · $currency',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const AppIcon(AppIcons.search, size: 22),
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            icon: const AppIcon(AppIcons.notifications, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spent This Month',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.formatDisplay(stats.totalSpentThisMonth),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _HeroStat(
                            label: 'Today',
                            value: provider.formatDisplay(stats.totalSpentToday),
                          ),
                          const SizedBox(width: 24),
                          _HeroStat(
                            label: 'Remaining',
                            value: provider.formatDisplay(stats.budgetRemaining),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: stats.budgetProgress,
                          minHeight: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(stats.budgetProgress * 100).toStringAsFixed(0)}% of ${provider.formatDisplay(stats.monthlyBudget)} budget',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Today',
                      value: provider.formatDisplay(stats.totalSpentToday),
                      iconAsset: AppIcons.clock,
                      iconColor: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Transactions',
                      value: '${provider.expenses.length}',
                      iconAsset: AppIcons.expenses,
                      iconColor: AppColors.primary,
                      onTap: () => context.go(AppRoutes.expenses),
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Spending by Category'),
            const CategorySpendingBars(),
            SectionHeader(
              title: 'Recent Transactions',
              actionLabel: 'See all',
              onActionTap: () => context.go(AppRoutes.expenses),
            ),
            ...stats.recentExpenseIds.map((id) {
              final expense = provider.expenseById(id)!;
              final category = provider.categoryById(expense.categoryId)!;
              return ExpenseTile(
                expense: expense,
                category: category,
                onTap: () => context.push('/expenses/$id'),
              );
            }),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Trend',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const MonthlyTrendChart(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
