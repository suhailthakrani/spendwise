import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/category.dart';
import '../../data/models/payment_method.dart';
import '../../data/providers/spendwise_data_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen({super.key, this.expenseId});

  final String? expenseId;

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  static const _kAnimDuration = Duration(milliseconds: 180);
  static const _kChipRadius = 12.0;
  static const _kFieldRadius = 14.0;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocus = FocusNode();

  late String _categoryId;
  late PaymentMethod _paymentMethod;
  late DateTime _date;
  bool _isRecurring = false;

  bool get isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    final provider = SpendWiseDataProvider.instance;
    final expense =
        widget.expenseId != null ? provider.expenseById(widget.expenseId!) : null;

    _categoryId = expense?.categoryId ?? provider.categories.first.id;
    _paymentMethod = expense?.paymentMethod ?? PaymentMethod.card;
    _date = expense?.date ?? DateTime(2026, 6, 25);
    _isRecurring = expense?.isRecurring ?? false;

    if (expense != null) {
      _amountController.text =
          provider.toDisplayAmount(expense.amount).toStringAsFixed(2);
      _noteController.text = expense.note;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isEditing) _amountFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Expense updated (design only)'
              : 'Expense saved (design only)',
        ),
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
    final provider = SpendWiseDataProvider.instance;
    final categories = provider.categories;
    final currencyCode = provider.displayCurrencyCode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const AppIcon(AppIcons.clear, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
        actions: [
          TextButton(
            onPressed: () => _save(context),
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                          fontSize: 42,
                          height: 1.08,
                          letterSpacing: -0.8,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          suffix: Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                              currencyCode,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _FieldLabel('Category'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 46,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            return _CompactCategoryChip(
                              category: cat,
                              selected: cat.id == _categoryId,
                              onTap: () => setState(() => _categoryId = cat.id),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Add a note (optional)',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(_kFieldRadius),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(_kFieldRadius),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(_kFieldRadius),
                            borderSide:
                                const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                            const SizedBox(width: 8),
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
                      const SizedBox(height: 12),
                      _FieldLabel('Payment'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: PaymentMethod.values.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final method = PaymentMethod.values[index];
                            return _PaymentChip(
                              method: method,
                              selected: method == _paymentMethod,
                              onTap: () =>
                                  setState(() => _paymentMethod = method),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _save(context),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kFieldRadius),
                  ),
                  backgroundColor: AppColors.primary,
                ),
                child: Text(isEditing ? 'Update' : 'Save Expense'),
              ),
              if (isEditing) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _confirmDelete(context),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Delete Expense'),
                ),
              ],
            ],
          ),
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
              context.go(AppRoutes.expenses);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense deleted (design only)')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
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
            ? category.color.withValues(alpha: 0.15)
            : Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius:
            BorderRadius.circular(_AddEditExpenseScreenState._kChipRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(_AddEditExpenseScreenState._kChipRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  AppIcons.categoryIcon(category.iconName),
                  size: 18,
                  color: category.color,
                ),
                const SizedBox(width: 6),
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
            : Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    fontSize: 12,
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
            : Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius:
            BorderRadius.circular(_AddEditExpenseScreenState._kChipRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(_AddEditExpenseScreenState._kChipRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
