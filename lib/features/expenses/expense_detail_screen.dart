import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(expenseDetailProvider(expenseId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);

    return expenseAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
      data: (expense) {
        if (expense == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              iconAsset: AppIcons.error,
              title: 'Expense not found',
            ),
          );
        }

        final categories = categoriesAsync.valueOrNull ?? [];
        final category = categoryById(categories, expense.categoryId);
        if (category == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              iconAsset: AppIcons.error,
              title: 'Category not found',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Details'),
            actions: [
              SoftIconButton(
                asset: AppIcons.edit,
                onPressed: () => context.push('/expenses/${expense.id}/edit'),
                size: 40,
                iconSize: 18,
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SoftIconButton(
                  asset: AppIcons.delete,
                  onPressed: () => _showDeleteDialog(context, ref),
                  size: 40,
                  iconSize: 18,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                  child: Column(
                    children: [
                      AppIconBox(
                        asset: AppIcons.categoryIcon(category.iconName),
                        color: category.color,
                        size: 72,
                        iconSize: 34,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currency.formatExpense(expense),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                          letterSpacing: -1,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        expense.note,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: category.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _DetailRow(
                        iconAsset: AppIcons.calendar,
                        label: 'Date',
                        value: DateFormatter.medium(expense.date),
                      ),
                      Divider(
                          height: 1,
                          indent: 68,
                          color: AppColors.border(context)),
                      _DetailRow(
                        iconAsset: AppIcons.clock,
                        label: 'Time',
                        value: DateFormatter.time(expense.date),
                      ),
                      Divider(
                          height: 1,
                          indent: 68,
                          color: AppColors.border(context)),
                      _DetailRow(
                        iconAsset: AppIcons.paymentIcon(
                            expense.paymentMethod.iconName),
                        label: 'Payment',
                        value: expense.paymentMethod.label,
                      ),
                      if (expense.isRecurring) ...[
                        Divider(
                            height: 1,
                            indent: 68,
                            color: AppColors.border(context)),
                        const _DetailRow(
                          iconAsset: AppIcons.repeat,
                          label: 'Type',
                          value: 'Recurring',
                          valueColor: AppColors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.push('/expenses/${expense.id}/edit'),
                child: const Text('Edit expense'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete expense?',
      message:
          'This expense will be removed permanently. This can’t be undone.',
      confirmLabel: 'Delete',
      iconAsset: AppIcons.delete,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(expenseRepositoryProvider).delete(expenseId);
    if (!context.mounted) return;
    context.go(AppRoutes.expenses);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted')),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          AppIconBox(
            asset: iconAsset,
            color: AppColors.primary,
            size: 40,
            iconSize: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 2),
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
