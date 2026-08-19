import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/chart_widgets.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/insights_period.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(insightsPeriodProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final report = ref.watch(insightsReportProvider);
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
      body: Column(
        children: [
          _InsightsPeriodFilter(
            selected: period,
            onSelected: (next) {
              if (next == period) return;
              HapticFeedback.selectionClick();
              ref.read(insightsPeriodProvider.notifier).state = next;
            },
          ),
          Expanded(
            child: expensesAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (_) {
                final categories = categoriesAsync.valueOrNull ?? [];
                final range = report.range;
                final history = report.history.reversed.toList();
                final trendValues = [
                  for (final summary in report.history) summary.totalExpenses,
                ];
                final trendLabels = [
                  for (final summary in report.history) summary.shortLabel,
                ];

                return ListView(
                  key: ValueKey(period),
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.navClearance,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.page,
                      ),
                      child: _SummaryTile(
                        label: period.spendLabel,
                        amount: currency.formatInUserCurrency(
                          range.totalExpenses,
                        ),
                        color: AppColors.primary,
                        iconAsset: AppIcons.expenses,
                      ),
                    ),
                    SectionHeader(
                      title: 'By category',
                      actionLabel: 'Details',
                      onActionTap: () => context.push(
                        AppRoutes.monthlySummary,
                        extra: range,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.page,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                          child: CategoryPieChart(
                            breakdown: range.categoryBreakdown,
                            categories: categories,
                          ),
                        ),
                      ),
                    ),
                    const SectionHeader(title: 'Spending trend'),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.page,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                period.rangeCaption,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondaryText(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              MonthlyTrendChart(
                                key: ValueKey(period),
                                height: 240,
                                values: trendValues,
                                labels: trendLabels,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SectionHeader(title: report.historyTitle),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.page,
                      ),
                      child: Card(
                        child: Column(
                          children: [
                            if (history.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No history in this range',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.secondaryText(context),
                                  ),
                                ),
                              )
                            else
                              for (var i = 0; i < history.length; i++) ...[
                                _HistoryTile(
                                  summary: history[i],
                                  amount: currency.formatInUserCurrency(
                                    history[i].totalExpenses,
                                  ),
                                ),
                                if (i < history.length - 1)
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
          ),
        ],
      ),
    );
  }
}

class _InsightsPeriodFilter extends StatelessWidget {
  const _InsightsPeriodFilter({
    required this.selected,
    required this.onSelected,
  });

  final InsightsPeriod selected;
  final ValueChanged<InsightsPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          4,
          AppSpacing.page,
          8,
        ),
        itemCount: InsightsPeriod.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = InsightsPeriod.values[index];
          return ChoiceChip(
            showCheckmark: false,
            label: Text(value.shortLabel),
            selected: selected == value,
            onSelected: (isSelected) {
              if (isSelected) onSelected(value);
            },
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.summary,
    required this.amount,
  });

  final PeriodSummary summary;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () => context.push(AppRoutes.monthlySummary, extra: summary),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Text(
          summary.leadingLabel,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      title: Text(summary.label),
      subtitle: Text('Expenses $amount'),
      trailing: Text(
        amount,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
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
