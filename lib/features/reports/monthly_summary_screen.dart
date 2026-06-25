import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/chart_widgets.dart';
import '../../data/providers/spendwise_data_provider.dart';

class MonthlySummaryScreen extends StatelessWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;
    final summary = provider.currentMonthSummary;
    final theme = Theme.of(context);

    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${months[summary.month]} ${summary.year} · ${provider.displayCurrencyCode}',
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
                  _BalanceRow(
                    label: 'Total Income',
                    amount: provider.formatDisplay(summary.totalIncome),
                    color: AppColors.success,
                  ),
                  const Divider(height: 32),
                  _BalanceRow(
                    label: 'Total Expenses',
                    amount: provider.formatDisplay(summary.totalExpenses),
                    color: AppColors.error,
                  ),
                  const Divider(height: 32),
                  _BalanceRow(
                    label: 'Balance',
                    amount: provider.formatDisplay(summary.balance),
                    color: summary.balance >= 0
                        ? AppColors.success
                        : AppColors.error,
                    isBold: true,
                  ),
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
                categories: provider.categories,
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
            final cat = provider.categoryById(e.key);
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
                provider.formatDisplay(e.value),
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
