import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final currencyCode = ref.watch(displayCurrencyCodeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses · $currencyCode'),
        actions: [
          IconButton(
            icon: const AppIcon(AppIcons.search, size: 22),
            onPressed: () => context.push(AppRoutes.search),
          ),
          IconButton(
            icon: const AppIcon(AppIcons.filter, size: 22),
            onPressed: () => context.push(AppRoutes.search),
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

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: expenses.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 76),
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final category = categoryById(categories, expense.categoryId);
              if (category == null) return const SizedBox.shrink();

              return Dismissible(
                key: ValueKey(expense.id),
                direction: DismissDirection.endToStart,
                background: const _SwipeDeleteBackground(),
                confirmDismiss: (_) => _confirmDeleteExpense(context),
                onDismissed: (_) async {
                  await ref.read(expenseRepositoryProvider).delete(expense.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Expense deleted')),
                    );
                  }
                },
                child: ExpenseTile(
                  expense: expense,
                  category: category,
                  onTap: () => context.push('/expenses/${expense.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
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
      color: AppColors.error,
      child: const AppIcon(
        AppIcons.delete,
        size: 22,
        color: Colors.white,
      ),
    );
  }
}
