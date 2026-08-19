import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/goal_pace_calculator.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/goal_status.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(savingGoalDetailProvider(goalId));
    final contributionsAsync = ref.watch(goalContributionsProvider(goalId));
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);

    return goalAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (goal) {
        if (goal == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Goal not found')),
          );
        }

        final required = GoalPaceCalculator.requiredThisMonth(goal);
        final title = goal.hasWishlist ? goal.wishlistTitle! : goal.name;

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () => context.push('/goals/$goalId/edit'),
                icon: const AppIcon(AppIcons.edit, size: 20),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, ref),
                icon: const AppIcon(AppIcons.delete, size: 20),
              ),
            ],
          ),
          floatingActionButton: goal.status == GoalStatus.active &&
                  !goal.isAchieved
              ? FloatingActionButton.extended(
                  onPressed: () => context.push('/goals/$goalId/contribute'),
                  icon: const AppIcon(AppIcons.add, size: 20),
                  label: const Text('Log savings'),
                )
              : null,
          body: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  8,
                  AppSpacing.page,
                  0,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (goal.hasWishlist && goal.name != goal.wishlistTitle)
                          Text(
                            goal.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText(context),
                            ),
                          ),
                        Text(
                          currency.formatDisplay(goal.savedAmount),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'of ${currency.formatDisplay(goal.targetAmount)} · ${(goal.progress * 100).round()}%',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryText(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.full),
                          child: LinearProgressIndicator(
                            value: goal.progress,
                            minHeight: 10,
                            backgroundColor: AppColors.softFill(context),
                            color: goal.isAchieved
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (goal.isAchieved)
                          const _InfoChip(
                            label: 'Goal achieved',
                            color: AppColors.success,
                          )
                        else ...[
                          if (required > 0)
                            Text(
                              'Save ${currency.formatDisplay(required)} this month to stay on pace',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          if (goal.deadline != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Deadline ${DateFormatter.short(goal.deadline!)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryText(context),
                              ),
                            ),
                          ],
                        ],
                        if (goal.wishlistNote != null &&
                            goal.wishlistNote!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            goal.wishlistNote!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SectionHeader(
                title: 'Contributions',
                actionLabel: goal.isAchieved ? null : 'Add',
                onActionTap: goal.isAchieved
                    ? null
                    : () => context.push('/goals/$goalId/contribute'),
              ),
              contributionsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error: $e'),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.page,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'No contributions yet. Log what you set aside.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText(context),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                    ),
                    child: Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < items.length; i++) ...[
                            ListTile(
                              leading: const AppIconBox(
                                asset: AppIcons.savings,
                                color: AppColors.success,
                                size: 40,
                                iconSize: 18,
                              ),
                              title: Text(
                                currency.formatDisplay(items[i].amount),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                [
                                  DateFormatter.short(items[i].date),
                                  if (items[i].note.isNotEmpty) items[i].note,
                                ].join(' · '),
                              ),
                              trailing: IconButton(
                                tooltip: 'Remove',
                                onPressed: () async {
                                  await ref
                                      .read(savingGoalRepositoryProvider)
                                      .deleteContribution(
                                        items[i].id,
                                        goalId,
                                      );
                                },
                                icon: const AppIcon(
                                  AppIcons.delete,
                                  size: 18,
                                ),
                              ),
                            ),
                            if (i < items.length - 1)
                              Divider(
                                height: 1,
                                indent: 70,
                                color: AppColors.border(context),
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete goal?',
      message: 'This removes the goal and all contribution history.',
      confirmLabel: 'Delete',
      iconAsset: AppIcons.delete,
    );
    if (!confirmed) return;
    await ref.read(savingGoalRepositoryProvider).delete(goalId);
    if (context.mounted) context.go(AppRoutes.goals);
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
