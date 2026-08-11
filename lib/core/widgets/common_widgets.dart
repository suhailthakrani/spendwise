import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/preferences_providers.dart';
import 'app_icon.dart';

class AmountText extends ConsumerWidget {
  const AmountText({
    super.key,
    required this.amount,
    this.style,
    this.color,
    this.showSign = false,
    this.compact = false,
  });

  final double amount;
  final TextStyle? style;
  final Color? color;
  final bool showSign;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyDisplayProvider);
    final formatted = currency.formatDisplay(amount, compact: compact);
    final prefix = showSign && amount > 0 ? '−' : '';

    return Text(
      '$prefix$formatted',
      style: (style ?? theme.textTheme.titleMedium)?.copyWith(
        color: color ??
            (showSign ? AppColors.error : theme.colorScheme.onSurface),
        fontWeight: FontWeight.w700,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.actionLabel,
    this.onActionTap,
    this.titleStyle,
    this.padding,
  });

  final String title;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ??
          const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xl,
            AppSpacing.page,
            AppSpacing.sm,
          ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: titleStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
            ),
          ),
          if (action != null)
            action!
          else if (actionLabel != null)
            TextButton(
              onPressed: onActionTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.iconAsset,
    this.iconColor,
    this.progress,
    this.onTap,
  });

  final String label;
  final String value;
  final String? subtitle;
  final String? iconAsset;
  final Color? iconColor;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = AppColors.secondaryText(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (iconAsset != null && iconColor != null) ...[
                    AppIconBox(
                      asset: iconAsset!,
                      color: iconColor!,
                      size: 32,
                      iconSize: 16,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
              if (progress != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.full),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: AppColors.softFill(context),
                    color: progress! > 0.9
                        ? AppColors.warning
                        : AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.iconAsset,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String iconAsset;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = AppColors.secondaryText(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppIcon(iconAsset, size: 40, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: muted,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.iconAsset,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  final String iconAsset;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: 2,
      ),
      leading: AppIconBox(
        asset: iconAsset,
        color: iconColor ?? AppColors.primary,
        size: 42,
        iconSize: 20,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? AppIcon(
                  AppIcons.chevronRight,
                  size: 18,
                  color: AppColors.tertiaryText(context),
                )
              : null),
    );
  }
}

/// Soft surface panel used for grouped settings / list blocks.
class SurfaceGroup extends StatelessWidget {
  const SurfaceGroup({
    super.key,
    required this.children,
    this.margin,
    this.padding,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ??
          const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Card(
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
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
    );
  }
}

/// Day separator with optional daily total — standard in competitive trackers.
class DateGroupHeader extends StatelessWidget {
  const DateGroupHeader({
    super.key,
    required this.label,
    this.totalLabel,
  });

  final String label;
  final String? totalLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = AppColors.secondaryText(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: muted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          if (totalLabel != null)
            Text(
              totalLabel!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: muted,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}
