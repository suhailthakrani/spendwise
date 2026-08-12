import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

/// Minimal goals strip on Budget — only when active goals exist.
class GoalProgressBanner extends ConsumerWidget {
  const GoalProgressBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pace = ref.watch(monthlyGoalsPaceProvider);
    final primary = pace.primary;
    if (primary == null || pace.activeCount == 0) {
      return const SizedBox.shrink();
    }

    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);
    final label = primary.hasWishlist
        ? (primary.wishlistTitle ?? primary.name)
        : primary.name;

    final text = pace.activeCount == 1
        ? 'Save ${currency.formatAlreadyConverted(pace.primaryRequiredDisplay)} · $label'
        : 'Save ${currency.formatAlreadyConverted(pace.requiredDisplay)} across ${pace.activeCount} goals';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        8,
        AppSpacing.page,
        0,
      ),
      child: Material(
        color: AppColors.softFill(context),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          onTap: () => context.push(AppRoutes.goals),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const AppIcon(
                  AppIcons.savings,
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${(primary.progress * 100).round()}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 2),
                AppIcon(
                  AppIcons.chevronRight,
                  size: 14,
                  color: AppColors.tertiaryText(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
