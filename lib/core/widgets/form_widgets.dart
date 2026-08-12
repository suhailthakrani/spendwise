import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.iconAsset,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final String? iconAsset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (iconAsset != null) ...[
                  AppIcon(iconAsset!, size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class FormPickerTile extends StatelessWidget {
  const FormPickerTile({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.value,
    this.onTap,
  });

  final String iconAsset;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.inputDecorationTheme.fillColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              AppIcon(iconAsset, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodySmall),
                    Text(
                      value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const AppIcon(AppIcons.chevronRight, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class FormPreviewBanner extends StatelessWidget {
  const FormPreviewBanner({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    this.accentColor,
  });

  final String title;
  final String amount;
  final String subtitle;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
          ),
        ],
      ),
    );
  }
}

class FormStickyActions extends StatelessWidget {
  const FormStickyActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.destructiveLabel,
    this.onDestructive,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? destructiveLabel;
  final VoidCallback? onDestructive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: onPrimary,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppColors.primary,
          ),
          child: Text(primaryLabel),
        ),
        if (secondaryLabel != null && onSecondary != null) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onSecondary,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(secondaryLabel!),
          ),
        ],
        if (destructiveLabel != null && onDestructive != null) ...[
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onDestructive,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: Text(destructiveLabel!),
          ),
        ],
      ],
    );
  }
}

Future<T?> showSearchablePickerSheet<T>({
  required BuildContext context,
  required String title,
  required String searchHint,
  required List<T> items,
  required String Function(T) labelOf,
  required String Function(T) subtitleOf,
  required bool Function(T) isSelected,
  required String iconAsset,
  String Function(T)? trailingOf,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (ctx) {
      var query = '';
      return StatefulBuilder(
        builder: (context, setModalState) {
          final filtered = items.where((item) {
            final q = query.trim().toLowerCase();
            if (q.isEmpty) return true;
            return labelOf(item).toLowerCase().contains(q) ||
                subtitleOf(item).toLowerCase().contains(q);
          }).toList();

          final maxHeight = MediaQuery.sizeOf(ctx).height * 0.85;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(ctx).bottom,
            ),
            child: SizedBox(
              height: maxHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: Text(
                      title,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: searchHint,
                        prefixIcon: const Icon(Icons.search_rounded, size: 22),
                        isDense: true,
                      ),
                      onChanged: (value) => setModalState(() => query = value),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              'No matches',
                              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.secondaryText(ctx),
                                  ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              indent: 70,
                              color: AppColors.border(ctx),
                            ),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final selected = isSelected(item);
                              return ListTile(
                                leading: AppIconBox(
                                  asset: iconAsset,
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.accent,
                                  size: 42,
                                  iconSize: 20,
                                ),
                                title: Text(labelOf(item)),
                                subtitle: Text(subtitleOf(item)),
                                trailing: trailingOf != null
                                    ? Text(
                                        trailingOf(item),
                                        style: Theme.of(ctx)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: selected
                                                  ? AppColors.primary
                                                  : null,
                                            ),
                                      )
                                    : (selected
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: AppColors.primary,
                                          )
                                        : null),
                                onTap: () => Navigator.pop(ctx, item),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
