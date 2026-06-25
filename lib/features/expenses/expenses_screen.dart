import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../data/providers/spendwise_data_provider.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;
    final expenses = provider.expenses;

    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses · ${provider.displayCurrencyCode}'),
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
      body: expenses.isEmpty
          ? EmptyState(
              iconAsset: AppIcons.receiptEmpty,
              title: 'No expenses yet',
              subtitle:
                  'Start tracking your spending by adding your first expense.',
              actionLabel: 'Add Expense',
              onAction: () => context.push(AppRoutes.addExpense),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final category = provider.categoryById(expense.categoryId)!;
                return ExpenseTile(
                  expense: expense,
                  category: category,
                  onTap: () => context.push('/expenses/${expense.id}'),
                );
              },
            ),
    );
  }
}
