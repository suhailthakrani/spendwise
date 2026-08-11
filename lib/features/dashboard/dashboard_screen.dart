import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/utils/currency_display.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/chart_widgets.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../data/models/dashboard_stats.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (stats) {
          final expenses = expensesAsync.valueOrNull ?? [];
          final categories = categoriesAsync.valueOrNull ?? [];
          final now = DateTime.now();
          final transactionsThisMonth = expenses
              .where(
                (e) => e.date.year == now.year && e.date.month == now.month,
              )
              .length;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(expensesProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  toolbarHeight: 76,
                  title: _DashboardTitle(greeting: _greeting()),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: SoftIconButton(
                        asset: AppIcons.search,
                        onPressed: () => context.push(AppRoutes.search),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      4,
                      AppSpacing.page,
                      0,
                    ),
                    child: _SpendingHeroCard(
                      stats: stats,
                      currency: currency,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      14,
                      AppSpacing.page,
                      0,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Transactions',
                              value: '$transactionsThisMonth',
                              subtitle: transactionsThisMonth == 1
                                  ? 'This month'
                                  : 'This month',
                              iconAsset: AppIcons.expenses,
                              iconColor: AppColors.primary,
                              onTap: () => context.go(AppRoutes.expenses),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              label: 'Budget left',
                              value: stats.monthlyBudget > 0
                                  ? currency.formatInUserCurrency(
                                      stats.budgetRemaining
                                          .clamp(0, double.infinity),
                                    )
                                  : '—',
                              subtitle: stats.monthlyBudget > 0
                                  ? '${(stats.budgetProgress * 100).toStringAsFixed(0)}% used'
                                  : 'Set a budget',
                              iconAsset: AppIcons.wallet,
                              iconColor: AppColors.accent,
                              progress: stats.monthlyBudget > 0
                                  ? stats.budgetProgress.clamp(0.0, 1.0)
                                  : null,
                              onTap: () => context.go(AppRoutes.budget),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SectionHeader(title: 'Top categories'),
                ),
                const SliverToBoxAdapter(child: _DashboardCategoryBars()),
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: 'Recent activity',
                    actionLabel: stats.recentExpenseIds.isNotEmpty
                        ? 'See all'
                        : null,
                    onActionTap: stats.recentExpenseIds.isNotEmpty
                        ? () => context.go(AppRoutes.expenses)
                        : null,
                  ),
                ),
                if (stats.recentExpenseIds.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.page,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 28,
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: AppIcon(
                                    AppIcons.expenses,
                                    size: 26,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No transactions yet',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap Add to log your first spend',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondaryText(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.page,
                      ),
                      child: Card(
                        child: Column(
                          children: [
                            for (var i = 0;
                                i < stats.recentExpenseIds.length;
                                i++) ...[
                              Builder(
                                builder: (context) {
                                  final id = stats.recentExpenseIds[i];
                                  final expense = expenses
                                      .where((e) => e.id == id)
                                      .firstOrNull;
                                  if (expense == null) {
                                    return const SizedBox.shrink();
                                  }
                                  final category = categoryById(
                                    categories,
                                    expense.categoryId,
                                  );
                                  if (category == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return ExpenseTile(
                                    expense: expense,
                                    category: category,
                                    dense: true,
                                    onTap: () => context.push('/expenses/$id'),
                                  );
                                },
                              ),
                              if (i < stats.recentExpenseIds.length - 1)
                                Divider(
                                  height: 1,
                                  indent: 78,
                                  color: AppColors.border(context),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      8,
                      AppSpacing.page,
                      AppSpacing.navClearance,
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppIconBox(
                                  asset: AppIcons.reports,
                                  color: AppColors.primary,
                                  size: 36,
                                  iconSize: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Spending trend',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      Text(
                                        'Last 6 months',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color:
                                              AppColors.secondaryText(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.go(AppRoutes.reports),
                                  child: const Text('Insights'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const MonthlyTrendChart(showHeader: false),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _DashboardCategoryBars extends StatelessWidget {
  const _DashboardCategoryBars();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Card(
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: CategorySpendingBars(padded: false),
        ),
      ),
    );
  }
}

class _DashboardTitle extends StatelessWidget {
  const _DashboardTitle({required this.greeting});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = DateFormatter.monthYear(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          monthLabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SpendingHeroCard extends StatelessWidget {
  const _SpendingHeroCard({
    required this.stats,
    required this.currency,
  });

  final DashboardStats stats;
  final CurrencyDisplay currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasBudget = stats.monthlyBudget > 0;
    final progress = hasBudget ? stats.budgetProgress : 0.0;
    final isOverBudget =
        hasBudget && stats.totalSpentThisMonth > stats.monthlyBudget;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOverBudget
              ? const [
                  Color(0xFFE11D48),
                  Color(0xFFBE123C),
                  Color(0xFF9F1239),
                ]
              : const [
                  Color(0xFF0F766E),
                  Color(0xFF0D9488),
                  Color(0xFF0F766E),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: (isOverBudget ? AppColors.error : AppColors.primary)
                .withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Stack(
          children: [
            Positioned(
              top: -36,
              right: -24,
              child: _DecorCircle(
                size: 150,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Positioned(
              bottom: -48,
              left: -28,
              child: _DecorCircle(
                size: 130,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spent this month',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currency.formatInUserCurrency(
                                stats.totalSpentThisMonth,
                              ),
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.2,
                                height: 1.0,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasBudget)
                        _BudgetRing(
                          progress: progress,
                          label: '${(progress * 100).toStringAsFixed(0)}%',
                          isOverBudget: isOverBudget,
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _GlassStatChip(
                          label: 'Today',
                          value: currency.formatInUserCurrency(
                            stats.totalSpentToday,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _GlassStatChip(
                          label: hasBudget ? 'Remaining' : 'Budget',
                          value: hasBudget
                              ? currency.formatInUserCurrency(
                                  stats.budgetRemaining,
                                )
                              : 'Not set',
                        ),
                      ),
                    ],
                  ),
                  if (hasBudget) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.full),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        color: isOverBudget
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isOverBudget
                          ? 'Over by ${currency.formatInUserCurrency(stats.totalSpentThisMonth - stats.monthlyBudget)}'
                          : 'of ${currency.formatInUserCurrency(stats.monthlyBudget)} monthly budget',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 14),
                    Text(
                      'Set a monthly budget to stay on track',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _BudgetRing extends StatelessWidget {
  const _BudgetRing({
    required this.progress,
    required this.label,
    required this.isOverBudget,
  });

  final double progress;
  final String label;
  final bool isOverBudget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 74,
            height: 74,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 6.5,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: Colors.white,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  height: 1,
                ),
              ),
              Text(
                'used',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassStatChip extends StatelessWidget {
  const _GlassStatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
