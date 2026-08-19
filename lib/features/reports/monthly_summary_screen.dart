import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/utils/currency_display.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/chart_widgets.dart';
import '../../data/models/category.dart';
import '../../data/models/insights_period.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class MonthlySummaryScreen extends ConsumerWidget {
  const MonthlySummaryScreen({super.key, this.period});

  final PeriodSummary? period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencyDisplayProvider);
    final currencyCode = ref.watch(displayCurrencyCodeProvider);
    final selected = period;

    if (selected != null) {
      return _PeriodDetailScaffold(
        title: '${selected.label} · $currencyCode',
        totalExpenses: selected.totalExpenses,
        breakdown: selected.categoryBreakdown,
        categories: categoriesAsync.valueOrNull ?? [],
        currency: currency,
      );
    }

    final summaryAsync = ref.watch(currentMonthSummaryProvider);

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
        return _PeriodDetailScaffold(
          title:
              '${InsightsPeriod.monthFullNames[summary.month - 1]} ${summary.year} · $currencyCode',
          totalExpenses: summary.totalExpenses,
          breakdown: summary.categoryBreakdown,
          categories: categoriesAsync.valueOrNull ?? [],
          currency: currency,
        );
      },
    );
  }
}

class _PeriodDetailScaffold extends StatelessWidget {
  const _PeriodDetailScaffold({
    required this.title,
    required this.totalExpenses,
    required this.breakdown,
    required this.categories,
    required this.currency,
  });

  final String title;
  final double totalExpenses;
  final Map<String, double> breakdown;
  final List<ExpenseCategory> categories;
  final CurrencyDisplay currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _BalanceRow(
                label: 'Total Expenses',
                amount: currency.formatInUserCurrency(totalExpenses),
                color: AppColors.error,
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
                breakdown: breakdown,
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
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No expenses in this period',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText(context),
                ),
              ),
            )
          else
            ...entries.map((e) {
              final cat = categoryById(categories, e.key);
              if (cat == null) return const SizedBox.shrink();
              final pct =
                  totalExpenses > 0 ? (e.value / totalExpenses) * 100 : 0.0;

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
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
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
