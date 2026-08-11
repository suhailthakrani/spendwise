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
import '../../data/models/expense.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
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
              'Spending',
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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SoftIconButton(
              asset: AppIcons.search,
              onPressed: () => context.push(AppRoutes.search),
              size: 40,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SoftIconButton(
              asset: AppIcons.filter,
              onPressed: () => context.push(AppRoutes.search),
              size: 40,
            ),
          ),
        ],
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (expenses) {
          final categories = categoriesAsync.valueOrNull ?? [];

          if (expenses.isEmpty) {
            return EmptyState(
              iconAsset: AppIcons.receiptEmpty,
              title: 'No expenses yet',
              subtitle:
                  'Start tracking your spending by adding your first expense.',
              actionLabel: 'Add Expense',
              onAction: () => context.push(AppRoutes.addExpense),
            );
          }

          final groups = _groupByDate(expenses);

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
            itemCount: groups.length,
            itemBuilder: (context, groupIndex) {
              final group = groups[groupIndex];
              final dayTotal = group.expenses.fold<double>(
                0,
                (sum, e) => sum + e.amount,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DateGroupHeader(
                    label: DateFormatter.relative(group.date),
                    totalLabel: currency.formatDisplay(dayTotal, compact: true),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                    ),
                    child: Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < group.expenses.length; i++) ...[
                            Builder(
                              builder: (context) {
                                final expense = group.expenses[i];
                                final category = categoryById(
                                  categories,
                                  expense.categoryId,
                                );
                                if (category == null) {
                                  return const SizedBox.shrink();
                                }

                                return Dismissible(
                                  key: ValueKey(expense.id),
                                  direction: DismissDirection.endToStart,
                                  background: const _SwipeDeleteBackground(),
                                  confirmDismiss: (_) =>
                                      _confirmDeleteExpense(context),
                                  onDismissed: (_) async {
                                    await ref
                                        .read(expenseRepositoryProvider)
                                        .delete(expense.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Expense deleted'),
                                        ),
                                      );
                                    }
                                  },
                                  child: ExpenseTile(
                                    expense: expense,
                                    category: category,
                                    showDate: false,
                                    dense: true,
                                    onTap: () => context
                                        .push('/expenses/${expense.id}'),
                                  ),
                                );
                              },
                            ),
                            if (i < group.expenses.length - 1)
                              Divider(
                                height: 1,
                                indent: 74,
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
          );
        },
      ),
    );
  }

  List<_ExpenseDayGroup> _groupByDate(List<Expense> expenses) {
    final map = <DateTime, List<Expense>>{};
    for (final expense in expenses) {
      final key = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      map.putIfAbsent(key, () => []).add(expense);
    }

    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final key in keys)
        _ExpenseDayGroup(date: key, expenses: map[key]!),
    ];
  }
}

class _ExpenseDayGroup {
  const _ExpenseDayGroup({required this.date, required this.expenses});

  final DateTime date;
  final List<Expense> expenses;
}

Future<bool> _confirmDeleteExpense(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Expense'),
      content: const Text(
        'Are you sure you want to delete this expense? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: const AppIcon(
        AppIcons.delete,
        size: 22,
        color: Colors.white,
      ),
    );
  }
}
