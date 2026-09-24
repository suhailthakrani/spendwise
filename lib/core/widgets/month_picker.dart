import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import 'app_icon.dart';

/// Month/year picker dialog. Returns `DateTime(year, month)` or null.
Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialMonth,
  DateTime? firstMonth,
  DateTime? lastMonth,
}) {
  final first = firstMonth ?? DateTime(2020, 1);
  final last = lastMonth ?? DateTime(2035, 12);
  return showDialog<DateTime>(
    context: context,
    builder: (context) => _MonthPickerDialog(
      initialMonth: DateTime(initialMonth.year, initialMonth.month),
      firstMonth: DateTime(first.year, first.month),
      lastMonth: DateTime(last.year, last.month),
    ),
  );
}

class _MonthPickerDialog extends StatefulWidget {
  const _MonthPickerDialog({
    required this.initialMonth,
    required this.firstMonth,
    required this.lastMonth,
  });

  final DateTime initialMonth;
  final DateTime firstMonth;
  final DateTime lastMonth;

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    _year = widget.initialMonth.year;
    _month = widget.initialMonth.month;
  }

  bool _isAllowed(int year, int month) {
    final value = DateTime(year, month);
    return !value.isBefore(widget.firstMonth) &&
        !value.isAfter(widget.lastMonth);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      title: Row(
        children: [
          IconButton(
            tooltip: 'Previous year',
            onPressed: _isAllowed(_year - 1, _month)
                ? () => setState(() => _year -= 1)
                : null,
            icon: const RotatedBox(
              quarterTurns: 2,
              child: AppIcon(AppIcons.chevronRight, size: 20),
            ),
          ),
          Expanded(
            child: Text(
              '$_year',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next year',
            onPressed: _isAllowed(_year + 1, _month)
                ? () => setState(() => _year += 1)
                : null,
            icon: const AppIcon(AppIcons.chevronRight, size: 20),
          ),
        ],
      ),
      content: SizedBox(
        width: 280,
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final month = index + 1;
            final selected = month == _month;
            final enabled = _isAllowed(_year, month);
            return Material(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: enabled ? () => setState(() => _month = month) : null,
                child: Center(
                  child: Text(
                    _months[index],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: !enabled
                          ? (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight)
                          : selected
                              ? AppColors.primary
                              : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, DateTime(_year, _month)),
          child: const Text('Select'),
        ),
      ],
    );
  }
}

/// Prev / chip / next row used on Budget and Add Budget.
class MonthNavigator extends StatelessWidget {
  const MonthNavigator({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous month',
          onPressed: onPrevious,
          icon: const RotatedBox(
            quarterTurns: 2,
            child: AppIcon(AppIcons.chevronRight, size: 20),
          ),
        ),
        Expanded(
          child: Center(
            child: MonthSelectorChip(
              month: month,
              dense: true,
              onTap: onPick,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: onNext,
          icon: const AppIcon(AppIcons.chevronRight, size: 20),
        ),
      ],
    );
  }
}

/// Compact tappable month chip used on budget forms / headers.
class MonthSelectorChip extends StatelessWidget {
  const MonthSelectorChip({
    super.key,
    required this.month,
    required this.onTap,
    this.dense = false,
  });

  final DateTime month;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Theme.of(context).inputDecorationTheme.fillColor ??
          (isDark ? AppColors.darkSurface : AppColors.lightBackground),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 10 : 14,
            vertical: dense ? 8 : 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(
                AppIcons.calendar,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormatter.monthYear(month),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 4),
              AppIcon(
                AppIcons.arrowDown,
                size: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
