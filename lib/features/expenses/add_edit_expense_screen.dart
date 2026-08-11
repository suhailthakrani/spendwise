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
    final currency = ref.read(currencyDisplayProvider);

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
      _categoryId = categories.first.id;
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
    final categoriesAsync = ref.watch(categoriesProvider);
    final currencyCode = ref.watch(displayCurrencyCodeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categories = categoriesAsync.valueOrNull ?? [];

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
                        color: isDark
                            ? AppColors.darkCard
                            : Colors.white,
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
                              hintStyle:
                                  theme.textTheme.displaySmall?.copyWith(
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
                    const _FieldLabel('Category'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return _CompactCategoryChip(
                            category: cat,
                            selected: cat.id == _categoryId,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _categoryId = cat.id);
                            },
                          );
                        },
                      ),
                    ),
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
    return AnimatedContainer(
      duration: _AddEditExpenseScreenState._kAnimDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? category.color.withValues(alpha: 0.16)
            : AppColors.softFill(context),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: selected
              ? category.color.withValues(alpha: 0.45)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? category.color : null,
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
    return AnimatedContainer(
      duration: _AddEditExpenseScreenState._kAnimDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.softFill(context),
        borderRadius: BorderRadius.circular(AppRadii.sm),
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
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  AppIcons.paymentIcon(method.iconName),
                  size: 16,
                  color: selected ? AppColors.primary : null,
                ),
                const SizedBox(width: 6),
                Text(
                  method.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.primary : null,
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
