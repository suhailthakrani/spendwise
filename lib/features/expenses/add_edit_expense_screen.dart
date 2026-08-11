import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../../data/models/payment_method.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class AddEditExpenseScreen extends ConsumerStatefulWidget {
  const AddEditExpenseScreen({super.key, this.expenseId});

  final String? expenseId;

  @override
  ConsumerState<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends ConsumerState<AddEditExpenseScreen> {
  static const _kAnimDuration = Duration(milliseconds: 180);

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocus = FocusNode();

  late String _categoryId;
  late PaymentMethod _paymentMethod;
  late DateTime _date;
  bool _isRecurring = false;
  bool _initialized = false;

  bool get isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    _paymentMethod = PaymentMethod.card;
    _date = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  Future<void> _loadInitial() async {
    final categories =
        await ref.read(categoryRepositoryProvider).watchAll().first;
    final expenses =
        await ref.read(expenseRepositoryProvider).watchAll().first;
    final currency = ref.read(currencyDisplayProvider);

    final counts = <String, int>{};
    for (final expense in expenses) {
      counts[expense.categoryId] = (counts[expense.categoryId] ?? 0) + 1;
    }
    final ranked = [...categories]..sort((a, b) {
        final byCount = (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0);
        if (byCount != 0) return byCount;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    if (widget.expenseId != null) {
      final expense =
          await ref.read(expenseRepositoryProvider).getById(widget.expenseId!);
      if (!mounted || expense == null) return;
      _categoryId = expense.categoryId;
      _paymentMethod = expense.paymentMethod;
      _date = expense.date;
      _isRecurring = expense.isRecurring;
      _amountController.text =
          currency.toDisplayAmount(expense.amount).toStringAsFixed(2);
      _noteController.text = expense.note;
    } else {
      _categoryId = ranked.isNotEmpty ? ranked.first.id : categories.first.id;
      _amountFocus.requestFocus();
    }

    if (mounted) setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final amountDisplay = double.tryParse(_amountController.text);
    if (amountDisplay == null || amountDisplay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final currency = ref.read(currencyDisplayProvider);
    final repo = ref.read(expenseRepositoryProvider);
    final expense = Expense(
      id: widget.expenseId ?? repo.newId(),
      amount: currency.toStorageAmount(amountDisplay),
      categoryId: _categoryId,
      note: _noteController.text.trim().isEmpty
          ? 'Expense'
          : _noteController.text.trim(),
      date: _date,
      paymentMethod: _paymentMethod,
      isRecurring: _isRecurring,
    );

    if (isEditing) {
      await repo.update(expense);
    } else {
      await repo.create(expense);
    }

    if (!context.mounted) return;
    HapticFeedback.lightImpact();
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Expense updated' : 'Expense saved'),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final rankedCategories = ref.watch(categoriesByUsageProvider);
    final currencyCode = ref.watch(displayCurrencyCodeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categories = rankedCategories;
    final selected = categories.where((c) => c.id == _categoryId).firstOrNull;
    final preview = _visibleCategories(categories, selected);
    final hasMore = categories.length > preview.length;

    return Scaffold(
      appBar: AppBar(
        leading: SoftIconButton(
          asset: AppIcons.clear,
          onPressed: () => context.pop(),
          size: 40,
        ),
        leadingWidth: 64,
        title: Text(isEditing ? 'Edit expense' : 'New expense'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 28,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadii.xl),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            currencyCode,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.secondaryText(context),
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _amountController,
                            focusNode: _amountFocus,
                            onChanged: (_) => setState(() {}),
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 48,
                              height: 1.05,
                              letterSpacing: -1.2,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 48,
                                height: 1.05,
                                letterSpacing: -1.2,
                                color: AppColors.tertiaryText(context),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: _FieldLabel('Category')),
                        if (hasMore)
                          TextButton(
                            onPressed: () => _showAllCategories(
                              context,
                              categories,
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('View all'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasMore ? 'Most used' : 'Choose a category',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.tertiaryText(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final cat in preview)
                          _CompactCategoryChip(
                            category: cat,
                            selected: cat.id == _categoryId,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _categoryId = cat.id);
                            },
                          ),
                        if (hasMore)
                          _ViewAllChip(
                            onTap: () =>
                                _showAllCategories(context, categories),
                          ),
                      ],
                    ),
                    if (selected != null &&
                        !preview.any((c) => c.id == selected.id)) ...[
                      const SizedBox(height: 10),
                      _SelectedCategoryBanner(category: selected),
                    ],
                    const SizedBox(height: 20),
                    const _FieldLabel('Note'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _noteController,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'What was this for?',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _MetaChip(
                            iconAsset: AppIcons.calendar,
                            label: DateFormatter.relative(_date),
                            onTap: _pickDate,
                          ),
                        ),
                        if (isEditing) ...[
                          const SizedBox(width: 10),
                          _MetaChip(
                            iconAsset: AppIcons.repeat,
                            label: 'Repeat',
                            selected: _isRecurring,
                            onTap: () => setState(
                              () => _isRecurring = !_isRecurring,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    const _FieldLabel('Payment method'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PaymentMethod.values.map((method) {
                        return _PaymentChip(
                          method: method,
                          selected: method == _paymentMethod,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _paymentMethod = method);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () => _save(context),
                    child: Text(isEditing ? 'Update expense' : 'Save expense'),
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _confirmDelete(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: const Text('Delete expense'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows most-used categories first, always including the current selection.
  List<ExpenseCategory> _visibleCategories(
    List<ExpenseCategory> ranked,
    ExpenseCategory? selected, {
    int limit = 6,
  }) {
    if (ranked.length <= limit) return ranked;

    final visible = ranked.take(limit).toList();
    if (selected != null && !visible.any((c) => c.id == selected.id)) {
      visible[visible.length - 1] = selected;
    }
    return visible;
  }

  Future<void> _showAllCategories(
    BuildContext context,
    List<ExpenseCategory> categories,
  ) async {
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AllCategoriesSheet(
        categories: categories,
        selectedId: _categoryId,
      ),
    );

    if (selectedId != null && mounted) {
      setState(() => _categoryId = selectedId);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(expenseRepositoryProvider).delete(widget.expenseId!);
              context.go(AppRoutes.expenses);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense deleted')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryText(context),
            letterSpacing: 0.1,
          ),
    );
  }
}

class _ViewAllChip extends StatelessWidget {
  const _ViewAllChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppIcon(
                AppIcons.category,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'View all',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedCategoryBanner extends StatelessWidget {
  const _SelectedCategoryBanner({required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: category.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          AppIcon(
            AppIcons.categoryIcon(category.iconName),
            size: 18,
            color: category.color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Selected: ${category.name}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: category.color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllCategoriesSheet extends StatefulWidget {
  const _AllCategoriesSheet({
    required this.categories,
    required this.selectedId,
  });

  final List<ExpenseCategory> categories;
  final String selectedId;

  @override
  State<_AllCategoriesSheet> createState() => _AllCategoriesSheetState();
}

class _AllCategoriesSheetState extends State<_AllCategoriesSheet> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? widget.categories
        : widget.categories
            .where((c) => c.name.toLowerCase().contains(query))
            .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'All categories',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Most used appear first',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search categories',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12),
                        child: AppIcon(AppIcons.search, size: 20),
                      ),
                      prefixIconConstraints:
                          BoxConstraints(minWidth: 44, minHeight: 44),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No categories match',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 68,
                        color: AppColors.border(context),
                      ),
                      itemBuilder: (context, index) {
                        final cat = filtered[index];
                        final selected = cat.id == widget.selectedId;
                        return ListTile(
                          onTap: () => Navigator.pop(context, cat.id),
                          leading: AppIconBox(
                            asset: AppIcons.categoryIcon(cat.iconName),
                            color: cat.color,
                            size: 42,
                            iconSize: 20,
                          ),
                          title: Text(
                            cat.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: selected
                              ? const AppIcon(
                                  AppIcons.info,
                                  size: 20,
                                  color: AppColors.primary,
                                )
                              : null,
                          selected: selected,
                          selectedTileColor:
                              cat.color.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _CompactCategoryChip extends StatelessWidget {
  const _CompactCategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? category.color.withValues(alpha: 0.45)
        : AppColors.border(context);

    return Material(
      color: selected
          ? category.color.withValues(alpha: 0.16)
          : AppColors.softFill(context),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                AppIcons.categoryIcon(category.iconName),
                size: 18,
                color: category.color,
              ),
              const SizedBox(width: 8),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: selected ? category.color : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.primary.withValues(alpha: 0.45)
        : AppColors.border(context);

    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.12)
          : AppColors.softFill(context),
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                AppIcons.paymentIcon(method.iconName),
                size: 16,
                color: selected
                    ? AppColors.primary
                    : AppColors.secondaryText(context),
              ),
              const SizedBox(width: 6),
              Text(
                method.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: selected ? AppColors.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String iconAsset;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _AddEditExpenseScreenState._kAnimDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.softFill(context),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  iconAsset,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.primary : null,
                    ),
                    overflow: TextOverflow.ellipsis,
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
