import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/category_duplicates.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/category.dart';
import 'category_merge_sheet.dart';

/// Soft banner — only when leftover lookalike categories exist on device.
class CategoryMergeBanner extends ConsumerStatefulWidget {
  const CategoryMergeBanner({super.key, required this.categories});

  final List<ExpenseCategory> categories;

  @override
  ConsumerState<CategoryMergeBanner> createState() =>
      _CategoryMergeBannerState();
}

class _CategoryMergeBannerState extends ConsumerState<CategoryMergeBanner> {
  Set<String> _dismissed = {};
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final keys = await loadDismissedDuplicateKeys();
    if (!mounted) return;
    setState(() {
      _dismissed = keys;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    final pairs = findLikelyDuplicatePairs(widget.categories)
        .where((p) => !_dismissed.contains(p.dismissKey))
        .toList();
    if (pairs.isEmpty) return const SizedBox.shrink();

    final pair = pairs.first;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: () async {
            final merged = await showCategoryMergeSheet(context, pair: pair);
            if (!mounted) return;
            if (merged) {
              setState(() {});
            } else {
              await _load();
            }
          },
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(
              children: [
                const AppIcon(
                  AppIcons.category,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Possible duplicate',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${pair.left.name} and ${pair.right.name} look similar. Tap to merge.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Dismiss',
                  onPressed: () async {
                    await dismissDuplicatePair(pair);
                    if (!mounted) return;
                    await _load();
                  },
                  icon: AppIcon(
                    AppIcons.clear,
                    size: 16,
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
