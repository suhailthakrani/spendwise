import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/export_format.dart';
import '../../data/models/insights_period.dart';
import '../../data/models/user_preferences.dart';
import '../../features/account/account_screen.dart';
import '../../features/account/backup_screen.dart';
import '../../features/account/edit_profile_screen.dart';
import '../../features/account/export_screen.dart';
import '../../features/account/faq_screen.dart';
import '../../features/account/privacy_screen.dart';
import '../../features/account/settings_screen.dart';
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
import '../../features/goals/add_edit_goal_screen.dart';
import '../../features/goals/contribute_goal_screen.dart';
import '../../features/goals/goal_detail_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/reports/monthly_summary_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../providers/notification_providers.dart';
import '../../providers/preferences_providers.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
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
  static const goals = '/goals';
  static const addGoal = '/goals/add';
  static const goalDetail = '/goals/:id';
  static const editGoal = '/goals/:id/edit';
  static const contributeGoal = '/goals/:id/contribute';
  static const search = '/search';
  static const account = '/account';
  static const editProfile = '/account/edit';
  static const export = '/account/export';
  static const backup = '/account/backup';
  static const settings = '/account/settings';
  static const faq = '/account/faq';
  static const privacy = '/account/privacy';
  static const onboarding = '/onboarding';
  static const signin = '/signin';
  static const signup = '/signup';
  static const restore = '/restore';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  final analyticsObserver = ref.read(appAnalyticsProvider).navigatorObserver;

  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    observers: [
      if (analyticsObserver != null) analyticsObserver,
    ],
    redirect: (context, state) {
      final prefsAsync = ref.read(preferencesProvider);
      final loc = state.matchedLocation;
      final onSplash = loc == AppRoutes.splash;
      final onOnboarding = loc == AppRoutes.onboarding;
      final onAuth = loc == AppRoutes.signin ||
          loc == AppRoutes.signup ||
          loc == AppRoutes.restore;

      // Splash owns its own exit navigation after boot + min display time.
      if (onSplash) return null;

      if (prefsAsync.isLoading || !prefsAsync.hasValue) {
        return AppRoutes.splash;
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
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
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
      GoRoute(
        path: AppRoutes.restore,
        builder: (context, state) => const BackupScreen(restoreOnly: true),
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
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.backup,
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: AppRoutes.faq,
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) => const PrivacyScreen(),
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
        builder: (context, state) {
          final extra = state.extra;
          return MonthlySummaryScreen(
            period: extra is PeriodSummary ? extra : null,
          );
        },
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
      GoRoute(
        path: AppRoutes.goals,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addGoal,
        builder: (context, state) => const AddEditGoalScreen(),
      ),
      GoRoute(
        path: AppRoutes.editGoal,
        builder: (context, state) => AddEditGoalScreen(
          goalId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.contributeGoal,
        builder: (context, state) => ContributeGoalScreen(
          goalId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.goalDetail,
        builder: (context, state) => GoalDetailScreen(
          goalId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.export,
        builder: (context, state) => const ExportScreen(
          format: ExportFormat.excel,
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
