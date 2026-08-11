import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
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
    this.dense = false,
  });

  final Expense expense;
  final ExpenseCategory category;
  final VoidCallback? onTap;
  final bool showDate;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = AppColors.secondaryText(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.page,
            vertical: dense ? 10 : 12,
          ),
          child: Row(
            children: [
              AppIconBox(
                asset: AppIcons.categoryIcon(category.iconName),
                color: category.color,
                size: dense ? 42 : 46,
                iconSize: dense ? 20 : 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      showDate
                          ? '${category.name} · ${DateFormatter.relative(expense.date)}'
                          : category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AmountText(
                amount: expense.amount,
                showSign: true,
                compact: true,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        size: 16,
        color: selected ? Colors.white : category.color,
      ),
      label: Text(label),
      selectedColor: category.color,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
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
    this.showLabel = true,
  });

  final String label;
  final double spent;
  final double limit;
  final Color? color;
  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyDisplayProvider);
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final over = limit > 0 && spent > limit;
    final barColor = over
        ? AppColors.error
        : progress > 0.85
            ? AppColors.warning
            : (color ?? AppColors.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${currency.formatInUserCurrency(spent, compact: true)} / ${currency.formatInUserCurrency(limit, compact: true)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText(context),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        if (showLabel) const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.full),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: AppColors.softFill(context),
            color: barColor,
          ),
        ),
      ],
    );
  }
}
