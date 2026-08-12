import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/goal_pace_calculator.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/goal_status.dart';
import '../../data/models/saving_goal.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingGoalsProvider);
    final currency = ref.watch(currencyDisplayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saving goals'),
        actions: [
          IconButton(
            tooltip: 'Add goal',
            onPressed: () => context.push(AppRoutes.addGoal),
            icon: const AppIcon(AppIcons.add, size: 22),
          ),
        ],
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(
              iconAsset: AppIcons.savings,
              title: 'No saving goals yet',
              subtitle:
                  'Set a target — emergency fund, wishlist item, or anything you are saving for.',
              actionLabel: 'Add goal',
              onAction: () => context.push(AppRoutes.addGoal),
            );
          }

          final active = goals
              .where((g) => g.status == GoalStatus.active && !g.isAchieved)
              .toList();
          final done = goals
              .where((g) => g.status == GoalStatus.achieved || g.isAchieved)
              .toList();
          final other = goals
              .where(
                (g) =>
                    g.status == GoalStatus.paused ||
                    (g.status != GoalStatus.active &&
                        g.status != GoalStatus.achieved &&
                        !g.isAchieved),
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
            children: [
              if (active.isNotEmpty) ...[
                const SectionHeader(title: 'Active'),
                ...active.map(
                  (g) => _GoalTile(
                    goal: g,
                    monthlyRequired: currency.toDisplayAmount(
                      GoalPaceCalculator.requiredThisMonth(g),
                    ),
                  ),
                ),
              ],
              if (done.isNotEmpty) ...[
                const SectionHeader(title: 'Achieved'),
                ...done.map(
                  (g) => _GoalTile(
                    goal: g,
                    monthlyRequired: 0,
                  ),
                ),
              ],
              if (other.isNotEmpty) ...[
                const SectionHeader(title: 'Paused'),
                ...other.map(
                  (g) => _GoalTile(
                    goal: g,
                    monthlyRequired: 0,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _GoalTile extends ConsumerWidget {
  const _GoalTile({
    required this.goal,
    required this.monthlyRequired,
  });

  final SavingGoal goal;
  final double monthlyRequired;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);
    final title = goal.hasWishlist ? goal.wishlistTitle! : goal.name;
    final subtitle = goal.hasWishlist && goal.name != goal.wishlistTitle
        ? goal.name
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        10,
      ),
      child: Card(
        child: InkWell(
          onTap: () => context.push('/goals/${goal.id}'),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppIconBox(
                      asset: AppIcons.savings,
                      color: goal.isAchieved
                          ? AppColors.success
                          : AppColors.accent,
                      size: 42,
                      iconSize: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryText(context),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '${(goal.progress * 100).round()}%',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 7,
                    backgroundColor: AppColors.softFill(context),
                    color: goal.isAchieved
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${currency.formatDisplay(goal.savedAmount)} of ${currency.formatDisplay(goal.targetAmount)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ),
                    if (!goal.isAchieved && monthlyRequired > 0)
                      Text(
                        '${currency.formatAlreadyConverted(monthlyRequired)}/mo',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      )
                    else if (goal.deadline != null)
                      Text(
                        'By ${DateFormatter.short(goal.deadline!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.tertiaryText(context),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
