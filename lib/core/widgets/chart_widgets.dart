import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../../data/models/category.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../utils/category_lookup.dart';
import 'app_icon.dart';

class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({
    super.key,
    required this.breakdown,
    required this.categories,
    this.showCenterTotal = true,
  });

  final Map<String, double> breakdown;
  final List<ExpenseCategory> categories;
  final bool showCenterTotal;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.breakdown.isEmpty) {
      return _ChartEmptyState(
        title: 'No category data',
        subtitle: 'Add expenses to see your spending mix',
      );
    }

    final entries = widget.breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0, (s, e) => s + e.value);

    // Breakdown values are already in display currency from report repo.
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 66,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = null;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: List.generate(entries.length, (i) {
                    final cat = _categoryFor(entries[i].key);
                    final selected = _touchedIndex == i;
                    final pct =
                        total > 0 ? (entries[i].value / total) * 100 : 0.0;

                    return PieChartSectionData(
                      value: entries[i].value,
                      color: cat.color,
                      // fl_chart: radius == ring stroke thickness, not outer size
                      radius: selected ? 20 : 16,
                      title: '',
                      badgeWidget: selected && pct >= 5
                          ? _DonutPercentBadge(percent: pct)
                          : null,
                      badgePositionPercentageOffset: 1.35,
                    );
                  }),
                ),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
              ),
              if (widget.showCenterTotal)
                Consumer(
                  builder: (context, ref, _) {
                    final currency = ref.watch(currencyDisplayProvider);
                    final touched = _touchedIndex != null &&
                        _touchedIndex! >= 0 &&
                        _touchedIndex! < entries.length;
                    final label = touched
                        ? _categoryFor(entries[_touchedIndex!].key).name
                        : 'Total';
                    final amount =
                        touched ? entries[_touchedIndex!].value : total;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.secondaryText(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currency.formatInUserCurrency(amount, compact: true),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, _) {
            final currency = ref.watch(currencyDisplayProvider);
            return Column(
              children: [
                for (var i = 0; i < entries.take(6).length; i++) ...[
                  _CategoryLegendRow(
                    category: _categoryFor(entries[i].key),
                    amount: currency.formatInUserCurrency(entries[i].value),
                    percentage:
                        total > 0 ? (entries[i].value / total) * 100 : 0,
                    selected: _touchedIndex == i,
                    onTap: () => setState(() {
                      _touchedIndex = _touchedIndex == i ? null : i;
                    }),
                  ),
                  if (i < entries.take(6).length - 1)
                    Divider(
                      height: 1,
                      color: AppColors.border(context).withValues(alpha: 0.6),
                    ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  ExpenseCategory _categoryFor(String id) {
    return widget.categories.firstWhere(
      (c) => c.id == id,
      orElse: () => widget.categories.isNotEmpty
          ? widget.categories.first
          : ExpenseCategory(
              id: id,
              name: 'Other',
              iconName: 'category',
              color: AppColors.primary,
            ),
    );
  }
}

class _DonutPercentBadge extends StatelessWidget {
  const _DonutPercentBadge({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '${percent.toStringAsFixed(0)}%',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
      ),
    );
  }
}

class _CategoryLegendRow extends StatelessWidget {
  const _CategoryLegendRow({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final String amount;
  final double percentage;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected
          ? category.color.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              AppIconBox(
                asset: AppIcons.categoryIcon(category.iconName),
                color: category.color,
                size: 36,
                iconSize: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${percentage.toStringAsFixed(0)}% of spending',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MonthlyTrendChart extends ConsumerStatefulWidget {
  const MonthlyTrendChart({
    super.key,
    this.height = 220,
    this.showHeader = true,
    this.values,
    this.labels,
  });

  final double height;
  final bool showHeader;
  final List<double>? values;
  final List<String>? labels;

  @override
  ConsumerState<MonthlyTrendChart> createState() => _MonthlyTrendChartState();
}

class _MonthlyTrendChartState extends ConsumerState<MonthlyTrendChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final providedValues = widget.values;
    final providedLabels = widget.labels;
    if (providedValues != null && providedLabels != null) {
      return _chart(
        context,
        providedValues,
        providedLabels,
      );
    }

    final trendAsync = ref.watch(monthlyTrendProvider);
    final labels = ref.watch(monthlyTrendLabelsProvider);

    return trendAsync.when(
      loading: () => SizedBox(
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) => _chart(context, data, labels),
    );
  }

  Widget _chart(
    BuildContext context,
    List<double> data,
    List<String> labels,
  ) {
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (data.isEmpty) {
      return _ChartEmptyState(
        title: 'No trend yet',
        subtitle: 'Spend over a few months to unlock trends',
        height: widget.height,
      );
    }

    final peak = data.reduce((a, b) => a > b ? a : b);
    if (peak <= 0) {
      return _ChartEmptyState(
        title: 'No spending yet',
        subtitle: 'Your spending trend will appear here',
        height: widget.height,
      );
    }

    final maxY = peak * 1.25;
    final lastIndex = data.length - 1;
    final touched = _touchedIndex ?? lastIndex;
    final dense = data.length >= 10;
    final compact = data.length >= 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) ...[
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labels[touched.clamp(0, labels.length - 1)],
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.secondaryText(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currency.formatInUserCurrency(
                        data[touched.clamp(0, data.length - 1)],
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              if (data.length >= 2) _TrendDeltaChip(data: data),
            ],
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          height: widget.showHeader ? widget.height - 56 : widget.height,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              minY: 0,
              groupsSpace: dense ? 6 : (compact ? 10 : 14),
              barTouchData: BarTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.spot == null) {
                      return;
                    }
                    _touchedIndex = response.spot!.touchedBarGroupIndex;
                  });
                },
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 0,
                  getTooltipItem: (_, __, ___, ____) => null,
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 3,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFF0A0F1A).withValues(alpha: 0.05),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: maxY / 3,
                    getTitlesWidget: (value, meta) {
                      if (value <= 0 || value >= maxY) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          currency.formatInUserCurrency(
                            value,
                            compact: true,
                          ),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.tertiaryText(context),
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      final active = index == touched;
                      final skip = dense && index.isOdd && !active;
                      if (skip) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          labels[index],
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: active
                                ? AppColors.primary
                                : AppColors.tertiaryText(context),
                            fontWeight:
                                active ? FontWeight.w700 : FontWeight.w500,
                            fontSize: dense ? 9 : 11,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(data.length, (i) {
                final active = i == touched;
                final isLatest = i == lastIndex;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: data[i] <= 0 ? 0.001 : data[i],
                      width: dense
                          ? (active ? 12 : 8)
                          : compact
                              ? (active ? 16 : 12)
                              : (active ? 22 : 16),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: active || isLatest
                            ? [
                                AppColors.primary.withValues(alpha: 0.75),
                                AppColors.primary,
                              ]
                            : [
                                AppColors.primary.withValues(alpha: 0.18),
                                AppColors.primary.withValues(alpha: 0.42),
                              ],
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFF0A0F1A).withValues(alpha: 0.04),
                      ),
                    ),
                  ],
                );
              }),
            ),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
          ),
        ),
      ],
    );
  }
}

class _TrendDeltaChip extends StatelessWidget {
  const _TrendDeltaChip({required this.data});

  final List<double> data;

  @override
  Widget build(BuildContext context) {
    final current = data.last;
    final previous = data[data.length - 2];
    if (previous <= 0 && current <= 0) return const SizedBox.shrink();

    final delta =
        previous == 0 ? 100.0 : ((current - previous) / previous) * 100;
    final up = delta > 0.5;
    final flat = delta.abs() <= 0.5;
    final color = flat
        ? AppColors.secondaryText(context)
        : up
            ? AppColors.error
            : AppColors.success;
    final label = flat
        ? 'Same as previous'
        : '${up ? '+' : ''}${delta.toStringAsFixed(0)}% vs previous';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class CategorySpendingBars extends ConsumerWidget {
  const CategorySpendingBars({super.key, this.padded = true});

  final bool padded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);

    return statsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (stats) {
        final categories = categoriesAsync.valueOrNull ?? [];
        if (stats.categorySpending.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: padded ? AppSpacing.page : 16,
              vertical: 16,
            ),
            child: Text(
              'Category breakdown appears after you add expenses',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
              ),
            ),
          );
        }

        return Column(
          children: stats.categorySpending.take(5).map((cs) {
            final cat = categoryById(categories, cs.categoryId);
            if (cat == null) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: padded ? AppSpacing.page : 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  AppIconBox(
                    asset: AppIcons.categoryIcon(cat.iconName),
                    color: cat.color,
                    size: 40,
                    iconSize: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              currency.formatInUserCurrency(cs.amount),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.full),
                          child: LinearProgressIndicator(
                            value: (cs.percentage / 100).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: AppColors.softFill(context),
                            color: cat.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState({
    required this.title,
    required this.subtitle,
    this.height = 180,
  });

  final String title;
  final String subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: AppIcon(
                  AppIcons.reports,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
