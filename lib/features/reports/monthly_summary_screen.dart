import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/chart_widgets.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class MonthlySummaryScreen extends ConsumerWidget {
  const MonthlySummaryScreen({super.key});

  static const _months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(currentMonthSummaryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencyDisplayProvider);
    final currencyCode = ref.watch(displayCurrencyCodeProvider);
    final theme = Theme.of(context);

    return summaryAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
      data: (summary) {
        final categories = categoriesAsync.valueOrNull ?? [];
        final tracksIncome = summary.totalIncome > 0;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${_months[summary.month]} ${summary.year} · $currencyCode',
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (tracksIncome) ...[
                        _BalanceRow(
                          label: 'Total Income',
                          amount: currency.formatInUserCurrency(
                            summary.totalIncome,
                          ),
                          color: AppColors.success,
                        ),
                        const Divider(height: 32),
                      ],
                      _BalanceRow(
                        label: 'Total Expenses',
                        amount: currency.formatInUserCurrency(
                          summary.totalExpenses,
                        ),
                        color: AppColors.error,
                      ),
                      if (tracksIncome) ...[
                        const Divider(height: 32),
                        _BalanceRow(
                          label: 'Balance',
                          amount:
                              currency.formatInUserCurrency(summary.balance),
                          color: summary.balance >= 0
                              ? AppColors.success
                              : AppColors.error,
                          isBold: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Category Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CategoryPieChart(
                    breakdown: summary.categoryBreakdown,
                    categories: categories,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...summary.categoryBreakdown.entries.map((e) {
                final cat = categoryById(categories, e.key);
                if (cat == null) return const SizedBox.shrink();
                final pct = summary.totalExpenses > 0
                    ? (e.value / summary.totalExpenses) * 100
                    : 0.0;

                return ListTile(
                  leading: AppIconBox(
                    asset: AppIcons.categoryIcon(cat.iconName),
                    color: cat.color,
                    size: 40,
                    iconSize: 20,
                  ),
                  title: Text(cat.name),
                  subtitle: Text('${pct.toStringAsFixed(1)}% of total'),
                  trailing: Text(
                    currency.formatInUserCurrency(e.value),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.label,
    required this.amount,
    required this.color,
    this.isBold = false,
  });

  final String label;
  final String amount;
  final Color color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
        ),
      ],
    );
  }
}
