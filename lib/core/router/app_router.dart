import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/account_screen.dart';
import '../../features/account/edit_profile_screen.dart';
import '../../features/auth/signin_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/budget/add_edit_budget_screen.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/categories/category_detail_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/expenses/add_edit_expense_screen.dart';
import '../../features/expenses/expense_detail_screen.dart';
import '../../features/expenses/expenses_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/reports/monthly_summary_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../providers/preferences_providers.dart';
import '../../data/models/user_preferences.dart';

abstract final class AppRoutes {
  static const dashboard = '/';
  static const expenses = '/expenses';
  static const expenseDetail = '/expenses/:id';
  static const addExpense = '/expenses/add';
  static const editExpense = '/expenses/:id/edit';
  static const categories = '/categories';
  static const categoryDetail = '/categories/:id';
  static const reports = '/reports';
  static const monthlySummary = '/reports/monthly';
  static const budget = '/budget';
  static const addBudget = '/budget/add';
  static const editBudget = '/budget/:id/edit';
  static const search = '/search';
  static const account = '/account';
  static const editProfile = '/account/edit';
  static const onboarding = '/onboarding';
  static const signin = '/signin';
  static const signup = '/signup';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);

  final router = GoRouter(
    initialLocation: AppRoutes.signin,
    refreshListenable: refresh,
    redirect: (context, state) {
      final prefsAsync = ref.read(preferencesProvider);
      final loc = state.matchedLocation;
      final onOnboarding = loc == AppRoutes.onboarding;
      final onAuth = loc == AppRoutes.signin || loc == AppRoutes.signup;

      // Prefer auth routes while prefs stream is still warming up.
      if (prefsAsync.isLoading || !prefsAsync.hasValue) {
        return onOnboarding || onAuth ? null : AppRoutes.signin;
      }

      final prefs = prefsAsync.requireValue;

      if (!prefs.hasCompletedOnboarding) {
        return onOnboarding ? null : AppRoutes.onboarding;
      }

      if (!prefs.isSignedIn) {
        if (onAuth) return null;
        return AppRoutes.signin;
      }

      // Signed in: keep auth/onboarding screens away from the stack.
      if (onOnboarding || onAuth) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.signin,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExpensesScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.reports,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReportsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.budget,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BudgetScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.account,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AccountScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.addExpense,
        builder: (context, state) => const AddEditExpenseScreen(),
      ),
      GoRoute(
        path: AppRoutes.editExpense,
        builder: (context, state) => AddEditExpenseScreen(
          expenseId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.expenseDetail,
        builder: (context, state) => ExpenseDetailScreen(
          expenseId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.categoryDetail,
        builder: (context, state) => CategoryDetailScreen(
          categoryId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.monthlySummary,
        builder: (context, state) => const MonthlySummaryScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.addBudget,
        builder: (context, state) => const AddEditBudgetScreen(),
      ),
      GoRoute(
        path: AppRoutes.editBudget,
        builder: (context, state) => AddEditBudgetScreen(
          budgetId: state.pathParameters['id'],
        ),
      ),
    ],
  );

  ref.onDispose(refresh.dispose);
  return router;
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _sub = _ref.listen(preferencesProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<UserPreferences>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
