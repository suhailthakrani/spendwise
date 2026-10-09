import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../core/widgets/month_picker.dart';
import '../../data/models/budget.dart';
import '../../data/models/expense.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  var _didSyncActivePeriod = false;

  void _syncToActivePeriod(Budget? active) {
    if (_didSyncActivePeriod || active == null) return;
    _didSyncActivePeriod = true;
    final selected = ref.read(spendPeriodProvider);
    if (selected.year == active.year && selected.month == active.month) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(spendPeriodProvider.notifier).state =
          DateTime(active.year, active.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final activeBudget = ref.watch(activeOverallBudgetProvider);
    final selectedPeriod = ref.watch(spendPeriodProvider);
    final currency = ref.watch(currencyDisplayProvider);
    final currencyCode = ref.watch(displayCurrencyCodeProvider);
    final theme = Theme.of(context);

    _syncToActivePeriod(activeBudget);

    final startDay = activeBudget?.startDay ??
        ref
            .watch(budgetsProvider)
            .valueOrNull
            ?.where((b) => b.categoryId == null)
            .map((b) => b.startDay)
            .firstOrNull ??
        1;
    final periodStart = Budget.resolvePeriodStart(
      year: selectedPeriod.year,
      month: selectedPeriod.month,
      startDay: startDay,
    );
    final periodEnd = Budget.resolvePeriodEnd(
      year: selectedPeriod.year,
      month: selectedPeriod.month,
      startDay: startDay,
    );
    final periodLabel = DateFormatter.periodHeader(
      year: selectedPeriod.year,
      month: selectedPeriod.month,
      startDay: startDay,
    );

    Future<void> pickPeriod() async {
      final picked = await showMonthPicker(
        context: context,
        initialMonth: selectedPeriod,
      );
      if (picked != null) {
        ref.read(spendPeriodProvider.notifier).state =
            DateTime(picked.year, picked.month);
      }
    }

    void shiftPeriod(int delta) {
      ref.read(spendPeriodProvider.notifier).state = DateTime(
        selectedPeriod.year,
        selectedPeriod.month + delta,
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: AppSpacing.tabAppBarHeight,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Spending',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
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
            padding: const EdgeInsets.only(right: 16),
            child: SoftIconButton(
              asset: AppIcons.search,
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
          final periodExpenses = expenses.where((e) {
            final day = DateTime(e.date.year, e.date.month, e.date.day);
            return !day.isBefore(periodStart) && !day.isAfter(periodEnd);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  4,
                  AppSpacing.page,
                  8,
                ),
                child: MonthNavigator(
                  month: selectedPeriod,
                  label: periodLabel,
                  onPrevious: () => shiftPeriod(-1),
                  onNext: () => shiftPeriod(1),
                  onPick: pickPeriod,
                ),
              ),
              Expanded(
                child: periodExpenses.isEmpty
                    ? EmptyState(
                        iconAsset: AppIcons.receiptEmpty,
                        title: expenses.isEmpty
                            ? 'No expenses yet'
                            : 'No spending this period',
                        subtitle: expenses.isEmpty
                            ? 'Start tracking your spending by adding your first expense.'
                            : 'Nothing logged for $periodLabel yet.',
                        actionLabel: 'Add Expense',
                        onAction: () => context.push(AppRoutes.addExpense),
                      )
                    : Builder(
                        builder: (context) {
                          final groups = _groupByDate(periodExpenses);
                          return ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.navClearance,
                            ),
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
                                    totalLabel: currency.formatDisplay(
                                      dayTotal,
                                      compact: true,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.page,
                                    ),
                                    child: Card(
                                      child: Column(
                                        children: [
                                          for (var i = 0;
                                              i < group.expenses.length;
                                              i++) ...[
                                            Builder(
                                              builder: (context) {
                                                final expense =
                                                    group.expenses[i];
                                                final category = categoryById(
                                                  categories,
                                                  expense.categoryId,
                                                );
                                                if (category == null) {
                                                  return const SizedBox.shrink();
                                                }

                                                return Dismissible(
                                                  key: ValueKey(expense.id),
                                                  direction: DismissDirection
                                                      .endToStart,
                                                  background:
                                                      const _SwipeDeleteBackground(),
                                                  confirmDismiss: (_) =>
                                                      _confirmDeleteExpense(
                                                    context,
                                                  ),
                                                  onDismissed: (_) async {
                                                    await ref
                                                        .read(
                                                          expenseRepositoryProvider,
                                                        )
                                                        .delete(expense.id);
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Expense deleted',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: ExpenseTile(
                                                    expense: expense,
                                                    category: category,
                                                    showDate: false,
                                                    dense: true,
                                                    onTap: () => context.push(
                                                      '/expenses/${expense.id}',
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            if (i < group.expenses.length - 1)
                                              Divider(
                                                height: 1,
                                                indent: 74,
                                                color:
                                                    AppColors.border(context),
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
              ),
            ],
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
      for (final key in keys) _ExpenseDayGroup(date: key, expenses: map[key]!),
    ];
  }
}

class _ExpenseDayGroup {
  const _ExpenseDayGroup({required this.date, required this.expenses});

  final DateTime date;
  final List<Expense> expenses;
}

Future<bool> _confirmDeleteExpense(BuildContext context) {
  return showAppConfirmDialog(
    context: context,
    title: 'Delete expense?',
    message: 'This expense will be removed permanently. This can’t be undone.',
    confirmLabel: 'Delete',
    iconAsset: AppIcons.delete,
  );
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
