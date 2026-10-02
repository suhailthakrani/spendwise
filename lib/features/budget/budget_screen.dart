import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../core/widgets/goal_progress_banner.dart';
import '../../core/widgets/month_picker.dart';
import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/models/envelope.dart';
import '../../data/models/recurring_expense.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  var _didSyncActivePeriod = false;

  void _syncToActivePeriod(List<Budget> rawBudgets) {
    if (_didSyncActivePeriod) return;
    final selected = ref.read(budgetMonthProvider);
    final hasSelected = rawBudgets.any(
      (b) => b.year == selected.year && b.month == selected.month,
    );
    if (hasSelected) {
      _didSyncActivePeriod = true;
      return;
    }
    final active = Budget.activeOverall(rawBudgets);
    if (active != null) {
      _didSyncActivePeriod = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(budgetMonthProvider.notifier).state =
            DateTime(active.year, active.month);
      });
      return;
    }
    final overall = rawBudgets.where((b) => b.categoryId == null).firstOrNull;
    if (overall != null) {
      _didSyncActivePeriod = true;
      final anchor = Budget.anchorContaining(
        date: DateTime.now(),
        startDay: overall.startDay,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(budgetMonthProvider.notifier).state = anchor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final recurringAsync = ref.watch(recurringExpensesProvider);
    final autoPostAsync = ref.watch(autoPostQueueProvider);
    final envelopesAsync = ref.watch(envelopesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedMonth = ref.watch(budgetMonthProvider);
    final currency = ref.watch(currencyDisplayProvider);
    final currencyCode = ref.watch(displayCurrencyCodeProvider);
    final theme = Theme.of(context);

    Future<void> pickMonth() async {
      final picked = await showMonthPicker(
        context: context,
        initialMonth: selectedMonth,
      );
      if (picked != null) {
        ref.read(budgetMonthProvider.notifier).state =
            DateTime(picked.year, picked.month);
      }
    }

    void shiftMonth(int delta) {
      ref.read(budgetMonthProvider.notifier).state = DateTime(
        selectedMonth.year,
        selectedMonth.month + delta,
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: AppSpacing.tabAppBarHeight,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Budget',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                height: 1.1,
              ),
            ),
            Text(
              currencyCode,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Saving goals',
            onPressed: () => context.push(AppRoutes.goals),
            icon: const AppIcon(AppIcons.savings, size: 22),
          ),
          IconButton(
            tooltip: 'Add budget',
            onPressed: () => context.push(AppRoutes.addBudget),
            icon: const AppIcon(AppIcons.add, size: 22),
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (rawBudgets) {
          _syncToActivePeriod(rawBudgets);
          final categories = categoriesAsync.valueOrNull ?? [];
          final recurring = recurringAsync.valueOrNull ?? [];
          final autoPostQueue = autoPostAsync.valueOrNull ?? [];
          final envelopes = envelopesAsync.valueOrNull ?? [];
          final monthBudgets = rawBudgets
              .where(
                (b) =>
                    b.year == selectedMonth.year &&
                    b.month == selectedMonth.month,
              )
              .toList();
          final monthlyRaw =
              monthBudgets.where((b) => b.categoryId == null).firstOrNull;
          final categoryRaws =
              monthBudgets.where((b) => b.categoryId != null).toList();
          final monthlyBudget = monthlyRaw != null
              ? currency.budgetInDisplay(monthlyRaw)
              : null;
          final categoryBudgets =
              categoryRaws.map(currency.budgetInDisplay).toList();

          final startDay = monthlyRaw?.startDay ??
              rawBudgets
                  .where((b) => b.categoryId == null)
                  .map((b) => b.startDay)
                  .firstOrNull ??
              1;
          final periodLabel = DateFormatter.periodHeader(
            year: selectedMonth.year,
            month: selectedMonth.month,
            startDay: startDay,
          );

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
            children: [
              const GoalProgressBanner(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  4,
                  AppSpacing.page,
                  0,
                ),
                child: MonthNavigator(
                  month: selectedMonth,
                  label: periodLabel,
                  onPrevious: () => shiftMonth(-1),
                  onNext: () => shiftMonth(1),
                  onPick: pickMonth,
                ),
              ),
              if (monthBudgets.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: EmptyState(
                    iconAsset: AppIcons.budget,
                    title: 'Set your budget',
                    subtitle: 'Decide how much you want to spend this period.',
                    actionLabel: 'Set budget',
                    onAction: () => context.push(AppRoutes.addBudget),
                  ),
                )
              else ...[
              if (monthlyBudget != null && monthlyRaw != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    8,
                    AppSpacing.page,
                    0,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.xl),
                      gradient: monthlyBudget.isOverBudget
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.error.withValues(alpha: 0.14),
                                AppColors.error.withValues(alpha: 0.06),
                              ],
                            )
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF0F766E),
                                Color(0xFF0D9488),
                                Color(0xFF0F766E),
                              ],
                              stops: [0.0, 0.55, 1.0],
                            ),
                      boxShadow: monthlyBudget.isOverBudget
                          ? null
                          : [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.22),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                      border: monthlyBudget.isOverBudget
                          ? Border.all(
                              color: AppColors.error.withValues(alpha: 0.22),
                            )
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push(
                          '/budget/${monthlyRaw.id}/edit',
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: monthlyBudget.isOverBudget
                                          ? AppColors.error
                                              .withValues(alpha: 0.14)
                                          : Colors.white
                                              .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(AppRadii.md),
                                    ),
                                    child: AppIcon(
                                      monthlyBudget.isOverBudget
                                          ? AppIcons.warning
                                          : AppIcons.wallet,
                                      color: monthlyBudget.isOverBudget
                                          ? AppColors.error
                                          : Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Monthly budget',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: monthlyBudget.isOverBudget
                                                ? null
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateFormatter.budgetCycleLabel(
                                            monthlyBudget.periodStart,
                                            monthlyBudget.periodEnd,
                                          ),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: monthlyBudget.isOverBudget
                                                ? AppColors.secondaryText(
                                                    context,
                                                  )
                                                : Colors.white
                                                    .withValues(alpha: 0.78),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AppIcon(
                                    AppIcons.edit,
                                    size: 18,
                                    color: monthlyBudget.isOverBudget
                                        ? AppColors.secondaryText(context)
                                        : Colors.white.withValues(alpha: 0.8),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                currency.formatInUserCurrency(
                                  monthlyBudget.isOverBudget
                                      ? monthlyBudget.spent -
                                          monthlyBudget.effectiveLimit
                                      : monthlyBudget.remaining
                                          .clamp(0, double.infinity),
                                ),
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  color: monthlyBudget.isOverBudget
                                      ? AppColors.error
                                      : Colors.white,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.full),
                                child: LinearProgressIndicator(
                                  value: monthlyBudget.progress,
                                  minHeight: 8,
                                  backgroundColor: monthlyBudget.isOverBudget
                                      ? AppColors.softFill(context)
                                      : Colors.white.withValues(alpha: 0.2),
                                  color: monthlyBudget.isOverBudget
                                      ? AppColors.error
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${currency.formatInUserCurrency(monthlyBudget.spent)} spent of ${currency.formatInUserCurrency(monthlyBudget.effectiveLimit)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: monthlyBudget.isOverBudget
                                      ? AppColors.secondaryText(context)
                                      : Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    8,
                    AppSpacing.page,
                    0,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: const AppIconBox(
                        asset: AppIcons.wallet,
                        color: AppColors.primary,
                        size: 42,
                        iconSize: 20,
                      ),
                      title: const Text('Set a monthly budget'),
                      subtitle: Text(
                        'How much can you spend in $periodLabel?',
                      ),
                      trailing: const AppIcon(AppIcons.add, size: 20),
                      onTap: () => context.push(AppRoutes.addBudget),
                    ),
                  ),
                ),
              SectionHeader(
                title: 'Category budgets',
                actionLabel: 'Add',
                onActionTap: () => context.push(AppRoutes.addBudget),
              ),
              if (categoryBudgets.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No category budgets yet. Add one to cap spending by category.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.page,
                  ),
                  child: Card(
                    child: Column(
                      children: List.generate(categoryBudgets.length, (index) {
                        final b = categoryBudgets[index];
                        final raw = categoryRaws[index];
                        final cat = b.categoryId != null
                            ? categoryById(categories, b.categoryId!)
                            : null;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () =>
                                  context.push('/budget/${raw.id}/edit'),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    if (cat != null)
                                      AppIconBox(
                                        asset: AppIcons.categoryIcon(
                                          cat.iconName,
                                        ),
                                        color: cat.color,
                                        size: 42,
                                        iconSize: 20,
                                      )
                                    else
                                      const AppIconBox(
                                        asset: AppIcons.budget,
                                        color: AppColors.primary,
                                        size: 42,
                                        iconSize: 20,
                                      ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: BudgetProgressBar(
                                        label: b.name,
                                        spent: b.spent,
                                        limit: b.effectiveLimit,
                                        color: cat?.color,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AppIcon(
                                      AppIcons.chevronRight,
                                      size: 18,
                                      color: AppColors.tertiaryText(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < categoryBudgets.length - 1)
                              Divider(
                                height: 1,
                                indent: 70,
                                color: AppColors.border(context),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                ),
                child: Card(
                  child: Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      childrenPadding: const EdgeInsets.only(bottom: 8),
                      title: Text(
                        'More tools',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Recurring, envelopes, and goals',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                      children: [
                        if (autoPostQueue.isNotEmpty) ...[
                          const _AdvancedSubhead(title: 'Auto-post queue'),
                          for (var i = 0; i < autoPostQueue.length; i++)
                            ListTile(
                              title: Text(autoPostQueue[i].title),
                              subtitle: Text(
                                'Due ${DateFormatter.short(autoPostQueue[i].nextDueDate)}',
                              ),
                              trailing: FilledButton.tonal(
                                onPressed: () async {
                                  final repo = ref.read(
                                    recurringExpenseRepositoryProvider,
                                  );
                                  final expenses =
                                      ref.read(expenseRepositoryProvider);
                                  await repo.postNow(
                                    autoPostQueue[i],
                                    expenses: expenses,
                                    newExpenseId: expenses.newId,
                                  );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Posted to ledger'),
                                    ),
                                  );
                                },
                                child: const Text('Confirm'),
                              ),
                            ),
                        ],
                        if (recurring.isNotEmpty) ...[
                          const _AdvancedSubhead(title: 'Recurring'),
                          for (final bill in recurring)
                            _RecurringTile(
                              recurring: bill,
                              category: categoryById(
                                categories,
                                bill.categoryId,
                              ),
                            ),
                        ],
                        const _AdvancedSubhead(title: 'Envelopes'),
                        if (envelopes.isEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(
                              'Optional cash pots for specific spending.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondaryText(context),
                              ),
                            ),
                          )
                        else
                          for (final envelope in envelopes)
                            _EnvelopeTile(envelope: envelope),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () =>
                                _showAddEnvelopeDialog(context, ref),
                            icon: const AppIcon(AppIcons.add, size: 16),
                            label: const Text('Add envelope'),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const AppIconBox(
                            asset: AppIcons.savings,
                            color: AppColors.accent,
                            size: 40,
                            iconSize: 18,
                          ),
                          title: const Text('Saving goals'),
                          subtitle: const Text('Wishlist and long-term funds'),
                          trailing:
                              const AppIcon(AppIcons.chevronRight, size: 18),
                          onTap: () => context.push(AppRoutes.goals),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdvancedSubhead extends StatelessWidget {
  const _AdvancedSubhead({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryText(context),
            ),
      ),
    );
  }
}

Future<void> _showAddEnvelopeDialog(BuildContext context, WidgetRef ref) async {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final currency = ref.read(currencyDisplayProvider);
  final month = ref.read(budgetMonthProvider);

  final created = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('New envelope'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Allocated',
                prefixText: '${currency.symbol} ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      );
    },
  );

  if (created != true) {
    nameController.dispose();
    amountController.dispose();
    return;
  }

  final allocatedDisplay = currency.parseInput(amountController.text) ?? 0;
  final repo = ref.read(envelopeRepositoryProvider);
  await repo.create(
    Envelope(
      id: repo.newId(),
      name: nameController.text.trim().isEmpty
          ? 'Envelope'
          : nameController.text.trim(),
      allocated: currency.toStorageAmount(allocatedDisplay),
      spent: 0,
      year: month.year,
      month: month.month,
    ),
  );
  nameController.dispose();
  amountController.dispose();
}

class _EnvelopeTile extends ConsumerWidget {
  const _EnvelopeTile({required this.envelope});

  final Envelope envelope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);
    return ListTile(
      title: Text(envelope.name),
      subtitle: Text(
        '${currency.format(envelope.spent)} spent · '
        '${currency.format(envelope.remaining)} left',
      ),
      trailing: Text(
        currency.format(envelope.allocated),
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RecurringTile extends ConsumerWidget {
  const _RecurringTile({
    required this.recurring,
    required this.category,
  });

  final RecurringExpense recurring;
  final ExpenseCategory? category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);

    final frequencyLabel = switch (recurring.frequency) {
      RecurrenceFrequency.weekly => 'Weekly',
      RecurrenceFrequency.monthly => 'Monthly',
      RecurrenceFrequency.yearly => 'Yearly',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          AppIconBox(
            asset: AppIcons.repeat,
            color: category?.color ?? AppColors.primary,
            size: 42,
            iconSize: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recurring.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$frequencyLabel · Due ${DateFormatter.short(recurring.nextDueDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: () async {
                      final repo =
                          ref.read(recurringExpenseRepositoryProvider);
                      final expenses = ref.read(expenseRepositoryProvider);
                      await repo.postNow(
                        recurring,
                        expenses: expenses,
                        newExpenseId: expenses.newId,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Posted ${recurring.title}'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Post now'),
                  ),
                ),
              ],
            ),
          ),
          Text(
            currency.formatDisplay(recurring.amount),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
