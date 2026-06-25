import 'package:go_router/go_router.dart';

import '../../features/budget/add_edit_budget_screen.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/expenses/expenses_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/account/account_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/categories/category_detail_screen.dart';
import '../../features/expenses/add_edit_expense_screen.dart';
import '../../features/expenses/expense_detail_screen.dart';
import '../../features/reports/monthly_summary_screen.dart';
import '../../features/search/search_screen.dart';

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
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
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
