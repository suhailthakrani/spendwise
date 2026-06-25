import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/providers/spendwise_data_provider.dart';

class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;
    final expense = provider.expenseById(expenseId);
    final theme = Theme.of(context);

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          iconAsset: AppIcons.error,
          title: 'Expense not found',
        ),
      );
    }

    final category = provider.categoryById(expense.categoryId)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const AppIcon(AppIcons.edit, size: 22),
            onPressed: () => context.push('/expenses/${expense.id}/edit'),
          ),
          IconButton(
            icon: const AppIcon(AppIcons.delete, size: 22, color: AppColors.error),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: AppIconBox(
              asset: AppIcons.categoryIcon(category.iconName),
              color: category.color,
              size: 72,
              iconSize: 36,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              provider.formatExpense(expense),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              expense.note,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          _DetailRow(
            iconAsset: AppIcons.category,
            label: 'Category',
            value: category.name,
            valueColor: category.color,
          ),
          _DetailRow(
            iconAsset: AppIcons.calendar,
            label: 'Date',
            value: DateFormatter.medium(expense.date),
          ),
          _DetailRow(
            iconAsset: AppIcons.clock,
            label: 'Time',
            value: DateFormatter.time(expense.date),
          ),
          _DetailRow(
            iconAsset: AppIcons.paymentIcon(expense.paymentMethod.iconName),
            label: 'Payment Method',
            value: expense.paymentMethod.label,
          ),
          if (expense.isRecurring)
            const _DetailRow(
              iconAsset: AppIcons.repeat,
              label: 'Type',
              value: 'Recurring expense',
              valueColor: AppColors.primary,
            ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => context.push('/expenses/${expense.id}/edit'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(AppIcons.edit, size: 20),
                SizedBox(width: 8),
                Text('Edit Expense'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text(
          'Are you sure you want to delete this expense? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.expenses);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense deleted (design only)')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.iconAsset,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String iconAsset;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          AppIcon(iconAsset, size: 22, color: AppColors.textSecondaryLight),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
