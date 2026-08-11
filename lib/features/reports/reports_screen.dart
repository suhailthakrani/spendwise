import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/chart_widgets.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const _months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
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
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (summary) {
          final categories = categoriesAsync.valueOrNull ?? [];
          final monthlySummaries = summariesAsync.valueOrNull ?? [];
          final tracksIncome = summary.totalIncome > 0;

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.page),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  child: Card(
                    color: summary.balance >= 0
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    child: ListTile(
                      leading: AppIconBox(
                        asset: summary.balance >= 0
                            ? AppIcons.savings
                            : AppIcons.warning,
                        color: summary.balance >= 0
                            ? AppColors.success
                            : AppColors.error,
                        size: 42,
                        iconSize: 20,
                      ),
                      title: const Text('Balance'),
                      subtitle: Text(
                        summary.balance >= 0
                            ? "You're in the green"
                            : 'Spending exceeds income',
                      ),
                      trailing: Text(
                        currency.formatInUserCurrency(summary.balance),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: summary.balance >= 0
                              ? AppColors.success
                              : AppColors.error,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      onTap: () => context.push(AppRoutes.monthlySummary),
                    ),
                  ),
                ),
              ],
              SectionHeader(
                title: 'By category',
                actionLabel: 'Details',
                onActionTap: () => context.push(AppRoutes.monthlySummary),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                    child: CategoryPieChart(
                      breakdown: summary.categoryBreakdown,
                      categories: categories,
                    ),
                  ),
                ),
              ),
              const SectionHeader(title: 'Spending trend'),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last 6 months',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const MonthlyTrendChart(height: 240),
                      ],
                    ),
                  ),
                ),
              ),
              const SectionHeader(title: 'Monthly history'),
              if (summariesAsync.isLoading && monthlySummaries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < monthlySummaries.length; i++) ...[
                          Builder(
                            builder: (context) {
                              final m = monthlySummaries[i];
                              return ListTile(
                                onTap: () =>
                                    context.push(AppRoutes.monthlySummary),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.sm),
                                  ),
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
                                      ? 'Income ${currency.formatInUserCurrency(m.totalIncome)}'
                                      : 'Expenses ${currency.formatInUserCurrency(m.totalExpenses)}',
                                ),
                                trailing: Text(
                                  m.totalIncome > 0
                                      ? currency
                                          .formatInUserCurrency(m.balance)
                                      : currency.formatInUserCurrency(
                                          m.totalExpenses,
                                        ),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: m.totalIncome > 0
                                        ? (m.balance >= 0
                                            ? AppColors.success
                                            : AppColors.error)
                                        : null,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (i < monthlySummaries.length - 1)
                            Divider(
                              height: 1,
                              indent: 76,
                              color: AppColors.border(context),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
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
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIconBox(
                  asset: iconAsset,
                  color: color,
                  size: 32,
                  iconSize: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              amount,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.4,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
