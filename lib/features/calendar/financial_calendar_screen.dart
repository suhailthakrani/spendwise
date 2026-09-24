import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/forecast.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class FinancialCalendarScreen extends ConsumerStatefulWidget {
  const FinancialCalendarScreen({super.key});

  @override
  ConsumerState<FinancialCalendarScreen> createState() =>
      _FinancialCalendarScreenState();
}

class _FinancialCalendarScreenState
    extends ConsumerState<FinancialCalendarScreen> {
  late DateTime _month;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      final lastDay = DateTime(_month.year, _month.month + 1, 0).day;
      final day = _selectedDay.day.clamp(1, lastDay);
      _selectedDay = DateTime(_month.year, _month.month, day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final forecast = ref.watch(forecastProvider).valueOrNull;
    final recurring = ref.watch(recurringExpensesProvider).valueOrNull ?? [];
    final budgets = ref.watch(budgetsProvider).valueOrNull ?? [];
    final goals = ref.watch(activeSavingGoalsProvider).valueOrNull ?? [];
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);

    final commitments = <_DayCommitment>[];

    for (final bill in recurring) {
      commitments.add(
        _DayCommitment(
          date: DateTime(
            bill.nextDueDate.year,
            bill.nextDueDate.month,
            bill.nextDueDate.day,
          ),
          title: bill.title,
          amount: bill.amount,
          kind: bill.entryType.name == 'income' ? 'Income' : 'Bill',
        ),
      );
    }

    for (final goal in goals) {
      final due = goal.deadline ??
          DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
      commitments.add(
        _DayCommitment(
          date: DateTime(due.year, due.month, due.day),
          title: 'Goal · ${goal.name}',
          amount: goal.monthlyTarget ?? 0,
          kind: 'Goal',
        ),
      );
    }

    for (final budget in budgets) {
      if (budget.startDate != null) {
        final d = budget.startDate!;
        commitments.add(
          _DayCommitment(
            date: DateTime(d.year, d.month, d.day),
            title: 'Budget starts · ${budget.name}',
            amount: budget.effectiveLimit,
            kind: 'Budget',
          ),
        );
      }
      if (budget.endDate != null) {
        final d = budget.endDate!;
        commitments.add(
          _DayCommitment(
            date: DateTime(d.year, d.month, d.day),
            title: 'Budget ends · ${budget.name}',
            amount: budget.effectiveLimit,
            kind: 'Budget',
          ),
        );
      }
    }

    if (forecast != null) {
      for (final c in forecast.upcomingCommitments) {
        final date = DateTime(c.date.year, c.date.month, c.date.day);
        final exists = commitments.any(
          (e) =>
              e.date == date &&
              e.title == c.title &&
              (e.amount - c.amount).abs() < 0.01,
        );
        if (!exists) {
          commitments.add(
            _DayCommitment(
              date: date,
              title: c.title,
              amount: c.amount,
              kind: switch (c.kind) {
                ForecastCommitmentKind.bill => 'Bill',
                ForecastCommitmentKind.income => 'Income',
                ForecastCommitmentKind.goal => 'Goal',
              },
            ),
          );
        }
      }
    }

    final daysWithItems = {
      for (final c in commitments)
        if (c.date.year == _month.year && c.date.month == _month.month)
          c.date.day,
    };

    final selectedItems = commitments
        .where(
          (c) =>
              c.date.year == _selectedDay.year &&
              c.date.month == _selectedDay.month &&
              c.date.day == _selectedDay.day,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _shiftMonth(-1),
                  icon: const RotatedBox(
                    quarterTurns: 2,
                    child: AppIcon(AppIcons.chevronRight, size: 20),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      DateFormatter.monthYear(_month),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _shiftMonth(1),
                  icon: const AppIcon(AppIcons.chevronRight, size: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: _MonthGrid(
                  month: _month,
                  selectedDay: _selectedDay,
                  markedDays: daysWithItems,
                  onSelect: (day) => setState(() => _selectedDay = day),
                ),
              ),
            ),
          ),
          SectionHeader(
            title: DateFormatter.medium(_selectedDay),
          ),
          if (selectedItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No commitments on this day',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Card(
                child: Column(
                  children: [
                    for (var i = 0; i < selectedItems.length; i++) ...[
                      ListTile(
                        leading: AppIconBox(
                          asset: AppIcons.calendar,
                          color: AppColors.primary,
                          size: 40,
                          iconSize: 18,
                        ),
                        title: Text(selectedItems[i].title),
                        subtitle: Text(selectedItems[i].kind),
                        trailing: selectedItems[i].amount > 0
                            ? Text(
                                currency.format(selectedItems[i].amount),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      if (i < selectedItems.length - 1)
                        Divider(
                          height: 1,
                          indent: 72,
                          color: AppColors.border(context),
                        ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCommitment {
  const _DayCommitment({
    required this.date,
    required this.title,
    required this.amount,
    required this.kind,
  });

  final DateTime date;
  final String title;
  final double amount;
  final String kind;
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDay,
    required this.markedDays,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Set<int> markedDays;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // Sun=0
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            for (final label in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondaryText(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startWeekday) {
              return const SizedBox.shrink();
            }
            final day = index - startWeekday + 1;
            final date = DateTime(month.year, month.month, day);
            final selected = selectedDay.year == date.year &&
                selectedDay.month == date.month &&
                selectedDay.day == date.day;
            final marked = markedDays.contains(day);

            return InkWell(
              onTap: () => onSelect(date),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.16)
                      : null,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: selected
                      ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                        color: selected ? AppColors.primary : null,
                      ),
                    ),
                    if (marked)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
