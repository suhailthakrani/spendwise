import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/constants/app_icons.dart';
import '../../core/widgets/bottom_nav.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/expenses')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/budget')) return 3;
    if (location.startsWith('/account')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
      case 1:
        context.go(AppRoutes.expenses);
      case 2:
        context.go(AppRoutes.reports);
      case 3:
        context.go(AppRoutes.budget);
      case 4:
        context.go(AppRoutes.account);
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _selectedIndex(context);
    final showFab = index == 0 || index == 1;

    return Scaffold(
      body: child,
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () => context.push(AppRoutes.addExpense),
              child: const AppIcon(
                AppIcons.add,
                size: 24,
                color: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SpendWiseBottomNav(
        selectedIndex: index,
        onSelected: (i) => _onTap(context, i),
      ),
    );
  }
}
