import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/category_duplicates.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/category.dart';
import '../../providers/data_providers.dart';
import '../../providers/repository_providers.dart';

/// Shows merge UI only when [pair] is provided (leftover duplicates).
Future<bool> showCategoryMergeSheet(
  BuildContext context, {
  required CategoryDuplicatePair pair,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _CategoryMergeSheet(pair: pair),
  );
  return result ?? false;
}

Future<void> dismissDuplicatePair(CategoryDuplicatePair pair) async {
  const storage = FlutterSecureStorage();
  await storage.write(
    key: 'category.merge.dismissed.${pair.dismissKey}',
    value: '1',
  );
}

Future<Set<String>> loadDismissedDuplicateKeys() async {
  const storage = FlutterSecureStorage();
  try {
    final all = await storage.readAll();
    return {
      for (final entry in all.entries)
        if (entry.key.startsWith('category.merge.dismissed.') &&
            entry.value == '1')
          entry.key.replaceFirst('category.merge.dismissed.', ''),
    };
  } catch (_) {
    return {};
  }
}

class _CategoryMergeSheet extends ConsumerStatefulWidget {
  const _CategoryMergeSheet({required this.pair});

  final CategoryDuplicatePair pair;

  @override
  ConsumerState<_CategoryMergeSheet> createState() =>
      _CategoryMergeSheetState();
}

class _CategoryMergeSheetState extends ConsumerState<_CategoryMergeSheet> {
  late ExpenseCategory _from;
  late ExpenseCategory _into;
  var _merging = false;

  @override
  void initState() {
    super.initState();
    _from = widget.pair.suggestedFrom;
    _into = widget.pair.suggestedInto;
  }

  void _swap() {
    setState(() {
      final tmp = _from;
      _from = _into;
      _into = tmp;
    });
  }

  Future<void> _merge() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Merge ${_from.name} into ${_into.name}?',
      message:
          'All spend in "${_from.name}" moves to "${_into.name}". '
          '"${_from.name}" is then removed. This can’t be undone.',
      confirmLabel: 'Merge',
      tone: AppConfirmTone.primary,
      iconAsset: AppIcons.category,
    );
    if (!confirmed || !mounted) return;

    setState(() => _merging = true);
    try {
      await ref.read(categoryRepositoryProvider).mergeInto(
            fromId: _from.id,
            intoId: _into.id,
          );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Merged into "${_into.name}"')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not merge — try again')),
      );
    } finally {
      if (mounted) setState(() => _merging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenses = ref.watch(expensesProvider).valueOrNull ?? [];
    final fromCount =
        expenses.where((e) => e.categoryId == _from.id).length;
    final intoCount =
        expenses.where((e) => e.categoryId == _into.id).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Merge categories',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Keep one category. Spend moves over safely.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText(context),
            ),
          ),
          const SizedBox(height: 18),
          _MergeCard(
            label: 'Merge from (will be removed)',
            category: _from,
            count: fromCount,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                TextButton.icon(
                  onPressed: _merging ? null : _swap,
                  icon: const AppIcon(AppIcons.sort, size: 16),
                  label: const Text('Swap'),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),
          _MergeCard(
            label: 'Keep',
            category: _into,
            count: intoCount,
            emphasize: true,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _merging ? null : _merge,
            child: Text(_merging ? 'Merging…' : 'Merge now'),
          ),
          TextButton(
            onPressed: _merging
                ? null
                : () async {
                    await dismissDuplicatePair(widget.pair);
                    if (context.mounted) Navigator.pop(context, false);
                  },
            child: const Text('Not duplicates'),
          ),
        ],
      ),
    );
  }
}

class _MergeCard extends StatelessWidget {
  const _MergeCard({
    required this.label,
    required this.category,
    required this.count,
    this.emphasize = false,
  });

  final String label;
  final ExpenseCategory category;
  final int count;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: emphasize
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.softFill(context),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: emphasize
              ? AppColors.primary.withValues(alpha: 0.35)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          AppIconBox(
            asset: AppIcons.categoryIcon(category.iconName),
            color: category.color,
            size: 44,
            iconSize: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryText(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  count == 0
                      ? 'No expenses'
                      : count == 1
                          ? '1 expense'
                          : '$count expenses',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
