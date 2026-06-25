import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/chart_widgets.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(currentMonthSummaryProvider);
    final summariesAsync = ref.watch(monthlySummariesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencyDisplayProvider);
    final currencyCode = ref.watch(displayCurrencyCodeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reports · $currencyCode'),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (summary) {
          final categories = categoriesAsync.valueOrNull ?? [];
          final monthlySummaries = summariesAsync.valueOrNull ?? [];
          final tracksIncome = summary.totalIncome > 0;

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: tracksIncome
                    ? Row(
                        children: [
                          Expanded(
                            child: _SummaryTile(
                              label: 'Income',
                              amount: currency.formatInUserCurrency(
                                summary.totalIncome,
                              ),
                              color: AppColors.success,
                              iconAsset: AppIcons.arrowDown,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryTile(
                              label: 'Expenses',
                              amount: currency.formatInUserCurrency(
                                summary.totalExpenses,
                              ),
                              color: AppColors.error,
                              iconAsset: AppIcons.arrowUp,
                            ),
                          ),
                        ],
                      )
                    : _SummaryTile(
                        label: 'Spent this month',
                        amount: currency.formatInUserCurrency(
                          summary.totalExpenses,
                        ),
                        color: AppColors.primary,
                        iconAsset: AppIcons.expenses,
                      ),
              ),
              if (tracksIncome) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    color: summary.balance >= 0
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    child: ListTile(
                      leading: AppIcon(
                        summary.balance >= 0
                            ? AppIcons.savings
                            : AppIcons.warning,
                        color: summary.balance >= 0
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      title: const Text('Balance'),
                      subtitle: Text(
                        summary.balance >= 0
                            ? "You're in the green"
                            : 'Spending exceeds income',
                      ),
                      trailing: Text(
                        currency.formatInUserCurrency(summary.balance),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: summary.balance >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      onTap: () => context.push(AppRoutes.monthlySummary),
                    ),
                  ),
                ),
              ],
              const SectionHeader(
                title: 'Spending by Category',
                actionLabel: 'Details',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CategoryPieChart(
                      breakdown: summary.categoryBreakdown,
                      categories: categories,
                    ),
                  ),
                ),
              ),
              const SectionHeader(title: 'Monthly Trend'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Last 6 months', style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        const MonthlyTrendChart(),
                      ],
                    ),
                  ),
                ),
              ),
              const SectionHeader(title: 'Monthly Summaries'),
              if (summariesAsync.isLoading && monthlySummaries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                ...monthlySummaries.map((m) {
                  return ListTile(
                    onTap: () => context.push(AppRoutes.monthlySummary),
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        _months[m.month].substring(0, 3),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text('${_months[m.month]} ${m.year}'),
                    subtitle: Text(
                      m.totalIncome > 0
                          ? 'Income: ${currency.formatInUserCurrency(m.totalIncome)} · '
                              'Expenses: ${currency.formatInUserCurrency(m.totalExpenses)}'
                          : 'Expenses: ${currency.formatInUserCurrency(m.totalExpenses)}',
                    ),
                    trailing: m.totalIncome > 0
                        ? Text(
                            currency.formatInUserCurrency(m.balance),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: m.balance >= 0
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          )
                        : Text(
                            currency.formatInUserCurrency(m.totalExpenses),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.iconAsset,
  });

  final String label;
  final String amount;
  final Color color;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(iconAsset, size: 18, color: color),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
