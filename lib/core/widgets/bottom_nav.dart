import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import 'app_icon.dart';

/// Standard Material 3 [NavigationBar] — edge-to-edge, not floating.
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
    _NavItem(asset: AppIcons.reports, label: 'Insights'),
    _NavItem(asset: AppIcons.budget, label: 'Budget'),
    _NavItem(asset: AppIcons.account, label: 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        HapticFeedback.selectionClick();
        onSelected(index);
      },
      destinations: [
        for (final item in _items)
          NavigationDestination(
            icon: AppIcon(
              item.asset,
              size: 22,
              color: AppColors.secondaryText(context),
            ),
            selectedIcon: AppIcon(
              item.asset,
              size: 22,
              color: AppColors.primary,
            ),
            label: item.label,
          ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem({required this.asset, required this.label});

  final String asset;
  final String label;
}
