import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../providers/data_providers.dart';

/// Whether the home “customize” tip should show. Hidden after dismiss.
final homeCustomizeTipVisibleProvider =
    StateNotifierProvider<_HomeCustomizeTipNotifier, AsyncValue<bool>>(
  (ref) => _HomeCustomizeTipNotifier(),
);

class _HomeCustomizeTipNotifier extends StateNotifier<AsyncValue<bool>> {
  _HomeCustomizeTipNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  static const _key = 'home.customize_tip_dismissed';
  final _storage = const FlutterSecureStorage();

  Future<void> _load() async {
    try {
      final dismissed = await _storage.read(key: _key);
      if (!mounted) return;
      state = AsyncValue.data(dismissed != '1');
    } catch (_) {
      if (!mounted) return;
      state = const AsyncValue.data(true);
    }
  }

  Future<void> dismiss() async {
    state = const AsyncValue.data(false);
    await _storage.write(key: _key, value: '1');
  }
}

/// Short tip pointing users at home customization.
///
/// Hidden until the user has logged a few expenses, and dismissible once.
class HomeCustomizeTip extends ConsumerWidget {
  const HomeCustomizeTip({super.key, this.minExpenseCount = 5});

  final int minExpenseCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseCount =
        ref.watch(expensesProvider).valueOrNull?.length ?? 0;
    if (expenseCount < minExpenseCount) return const SizedBox.shrink();

    final visible = ref.watch(homeCustomizeTipVisibleProvider).valueOrNull;
    if (visible != true) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        8,
        AppSpacing.page,
        0,
      ),
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          onTap: () async {
            await ref.read(homeCustomizeTipVisibleProvider.notifier).dismiss();
            if (!context.mounted) return;
            context.push(AppRoutes.customizeDashboard);
          },
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                const AppIcon(
                  AppIcons.edit,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can customize this home screen',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Dismiss',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  onPressed: () => ref
                      .read(homeCustomizeTipVisibleProvider.notifier)
                      .dismiss(),
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
