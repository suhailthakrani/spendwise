import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_icons.dart';
import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../../providers/preferences_providers.dart';
import 'app_icon.dart';
import 'common_widgets.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.category,
    this.onTap,
    this.showDate = true,
  });

  final Expense expense;
  final ExpenseCategory category;
  final VoidCallback? onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: AppIconBox(
        asset: AppIcons.categoryIcon(category.iconName),
        color: category.color,
      ),
      title: Text(
        expense.note,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        showDate
            ? '${category.name} · ${_relativeDate(expense.date)}'
            : category.name,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark
              ? const Color(0xFF94A3B8)
              : const Color(0xFF64748B),
        ),
      ),
      trailing: AmountText(
        amount: expense.amount,
        showSign: true,
        compact: true,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class CategoryChip extends ConsumerWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
    this.showAmount,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback? onTap;
  final double? showAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyDisplayProvider);
    final label = showAmount != null
        ? '${category.name} (${currency.formatDisplay(showAmount!, compact: true)})'
        : category.name;

    return FilterChip(
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      avatar: AppIcon(
        AppIcons.categoryIcon(category.iconName),
        size: 18,
        color: selected ? Colors.white : category.color,
      ),
      label: Text(label),
      selectedColor: category.color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}

class BudgetProgressBar extends ConsumerWidget {
  const BudgetProgressBar({
    super.key,
    required this.label,
    required this.spent,
    required this.limit,
    this.color,
  });

  final String label;
  final double spent;
  final double limit;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyDisplayProvider);
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final barColor = progress > 0.9
        ? const Color(0xFFEF4444)
        : (color ?? const Color(0xFF0D9488));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${currency.formatDisplay(spent, compact: true)} / ${currency.formatDisplay(limit, compact: true)}',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }
}
