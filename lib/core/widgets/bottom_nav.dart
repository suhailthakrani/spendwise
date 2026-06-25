import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

class SpendWiseBottomNav extends StatelessWidget {
  const SpendWiseBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    _NavItem(asset: AppIcons.home, label: 'Home'),
    _NavItem(asset: AppIcons.expenses, label: 'Spend'),
    _NavItem(asset: AppIcons.reports, label: 'Reports'),
    _NavItem(asset: AppIcons.budget, label: 'Budget'),
    _NavItem(asset: AppIcons.account, label: 'Account'),
  ];

  static const _barHeight = 76.0;
  static const _cornerRadius = 36.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barColor = isDark ? AppColors.darkSurface : Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: SafeArea(
        top: false,
        child: Material(
          color: barColor,
          elevation: isDark ? 16 : 12,
          shadowColor: isDark
              ? Colors.black.withValues(alpha: 0.45)
              : AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(_cornerRadius),
          child: SizedBox(
            height: _barHeight,
            child: Row(
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final selected = index == selectedIndex;
                return Expanded(
                  child: _NavButton(
                    item: item,
                    selected: selected,
                    isDark: isDark,
                    onTap: () => onSelected(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.asset, required this.label});

  final String asset;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final activeColor =
        isDark ? AppColors.primaryLight : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpendWiseBottomNav._cornerRadius),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: AppIcon(
                  item.asset,
                  size: 24,
                  color: selected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? activeColor : inactiveColor,
                  height: 1.1,
                  letterSpacing: -0.1,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
