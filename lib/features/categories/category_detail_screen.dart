import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/utils/currency_display.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../data/models/expense.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import 'category_editor_sheet.dart';

class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final expensesAsync = ref.watch(categoryExpensesProvider(categoryId));
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);

    final category = categoryById(
      categoriesAsync.valueOrNull ?? [],
      categoryId,
    );

    if (categoriesAsync.isLoading && category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          iconAsset: AppIcons.error,
          title: 'Category not found',
        ),
      );
    }

    return expensesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(category.name)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(category.name)),
        body: Center(child: Text('Error: $error')),
      ),
      data: (expenses) {
        final insights = _CategoryInsights.from(expenses, currency);
        final monthGroups = _monthsDescending(expenses, currency);

        return Scaffold(
          appBar: AppBar(
            title: Text(category.name),
            actions: [
              if (category.isCustom)
                IconButton(
                  tooltip: 'Edit',
                  icon: const AppIcon(AppIcons.edit, size: 22),
                  onPressed: () => showCategoryEditorSheet(
                    context,
                    category: category,
                  ),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AppIconBox(
                          asset: AppIcons.categoryIcon(category.iconName),
                          color: category.color,
                          size: 56,
                          iconSize: 28,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          currency.formatInUserCurrency(insights.thisMonth),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'This month'
                          '${insights.thisMonthCount == 0 ? '' : ' · ${insights.thisMonthCount}'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryText(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatChip(
                                label: 'All time',
                                value: currency
                                    .formatInUserCurrency(insights.allTime),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatChip(
                                label: 'Avg / month',
                                value: insights.monthCount == 0
                                    ? '—'
                                    : currency.formatInUserCurrency(
                                        insights.averageMonth,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _StatChip(
                                label: 'Highest',
                                value: insights.highestLabel == null
                                    ? '—'
                                    : currency.formatInUserCurrency(
                                        insights.highestAmount,
                                      ),
                                caption: insights.highestLabel,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SectionHeader(title: 'By month'),
              if (monthGroups.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: EmptyState(
                    iconAsset: AppIcons.receiptEmpty,
                    title: 'No spend in this category yet',
                  ),
                )
              else
                ...monthGroups.map((month) {
                  final isOpen = month.key == insights.thisMonthKey;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Card(
                      child: ExpansionTile(
                        initiallyExpanded: isOpen,
                        tilePadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        childrenPadding: EdgeInsets.zero,
                        title: Text(
                          month.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          '${month.count == 1 ? '1 expense' : '${month.count} expenses'}'
                          ' · ${currency.formatInUserCurrency(month.total)}',
                        ),
                        children: [
                          for (final expense in month.expenses)
                            ExpenseTile(
                              expense: expense,
                              category: category,
                              onTap: () =>
                                  context.push('/expenses/${expense.id}'),
                            ),
                        ],
                      ),
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

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.softFill(context),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.secondaryText(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.tertiaryText(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthSpend {
  const _MonthSpend({
    required this.key,
    required this.label,
    required this.total,
    required this.count,
    required this.expenses,
  });

  final String key;
  final String label;
  final double total;
  final int count;
  final List<Expense> expenses;
}

class _CategoryInsights {
  const _CategoryInsights({
    required this.thisMonth,
    required this.thisMonthCount,
    required this.thisMonthKey,
    required this.allTime,
    required this.averageMonth,
    required this.monthCount,
    required this.highestAmount,
    required this.highestLabel,
  });

  final double thisMonth;
  final int thisMonthCount;
  final String thisMonthKey;
  final double allTime;
  final double averageMonth;
  final int monthCount;
  final double highestAmount;
  final String? highestLabel;

  factory _CategoryInsights.from(
    List<Expense> expenses,
    CurrencyDisplay currency,
  ) {
    final now = DateTime.now();
    final thisKey = _monthKey(now.year, now.month);
    var thisMonth = 0.0;
    var thisCount = 0;
    var allTime = 0.0;
    final byMonth = <String, double>{};

    for (final e in expenses) {
      final amount = currency.toDisplayAmount(e.amount);
      allTime += amount;
      final key = _monthKey(e.date.year, e.date.month);
      byMonth[key] = (byMonth[key] ?? 0) + amount;
      if (key == thisKey) {
        thisMonth += amount;
        thisCount += 1;
      }
    }

    String? highestLabel;
    var highestAmount = 0.0;
    for (final entry in byMonth.entries) {
      if (entry.value >= highestAmount) {
        highestAmount = entry.value;
        final parts = entry.key.split('-');
        highestLabel = DateFormatter.monthYear(
          DateTime(int.parse(parts[0]), int.parse(parts[1])),
        );
      }
    }

    final monthCount = byMonth.length;
    return _CategoryInsights(
      thisMonth: thisMonth,
      thisMonthCount: thisCount,
      thisMonthKey: thisKey,
      allTime: allTime,
      averageMonth: monthCount == 0 ? 0 : allTime / monthCount,
      monthCount: monthCount,
      highestAmount: highestAmount,
      highestLabel: highestLabel,
    );
  }
}

List<_MonthSpend> _monthsDescending(
  List<Expense> expenses,
  CurrencyDisplay currency,
) {
  final map = <String, List<Expense>>{};
  for (final e in expenses) {
    final key = _monthKey(e.date.year, e.date.month);
    map.putIfAbsent(key, () => []).add(e);
  }

  final keys = map.keys.toList()
    ..sort((a, b) => b.compareTo(a));

  final result = <_MonthSpend>[];
  for (final key in keys) {
    final list = [...map[key]!]..sort((a, b) => b.date.compareTo(a.date));
    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final total = list.fold<double>(
      0,
      (s, e) => s + currency.toDisplayAmount(e.amount),
    );
    result.add(
      _MonthSpend(
        key: key,
        label: DateFormatter.monthYear(DateTime(year, month)),
        total: total,
        count: list.length,
        expenses: list,
      ),
    );
  }
  return result;
}

String _monthKey(int year, int month) =>
    '$year-${month.toString().padLeft(2, '0')}';
