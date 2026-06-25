import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/providers/spendwise_data_provider.dart';

enum BudgetFormType { monthly, category }

class AddEditBudgetScreen extends StatefulWidget {
  const AddEditBudgetScreen({super.key, this.budgetId});

  final String? budgetId;

  @override
  State<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  static const _kAnimDuration = Duration(milliseconds: 180);
  static const _kChipRadius = 12.0;
  static const _kFieldRadius = 14.0;

  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  final _limitFocus = FocusNode();

  late BudgetFormType _type;
  String? _categoryId;
  double _alertThreshold = 0.8;

  bool get isEditing => widget.budgetId != null;

  static const _alertPresets = [0.7, 0.8, 0.9, 1.0];

  @override
  void initState() {
    super.initState();
    final provider = SpendWiseDataProvider.instance;
    final budget =
        widget.budgetId != null ? provider.budgetById(widget.budgetId!) : null;

    _type = budget?.categoryId != null
        ? BudgetFormType.category
        : BudgetFormType.monthly;
    _categoryId = budget?.categoryId ?? provider.categories.first.id;

    if (budget != null) {
      _nameController.text = budget.name;
      _limitController.text =
          provider.toDisplayAmount(budget.limit).toStringAsFixed(0);
    } else {
      _nameController.text = 'Monthly Budget';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isEditing) _limitFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    _limitFocus.dispose();
    super.dispose();
  }

  Budget? get _existingBudget => widget.budgetId != null
      ? SpendWiseDataProvider.instance.budgetById(widget.budgetId!)
      : null;

  bool get _showCategoryPicker =>
      _type == BudgetFormType.category || _existingBudget?.categoryId != null;

  void _save(BuildContext context) {
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Budget updated (design only)'
              : 'Budget created (design only)',
        ),
      ),
    );
  }

  void _selectType(BudgetFormType type) {
    final provider = SpendWiseDataProvider.instance;
    setState(() {
      _type = type;
      if (type == BudgetFormType.monthly) {
        _nameController.text = 'Monthly Budget';
        _categoryId = null;
      } else {
        _categoryId ??= provider.categories.first.id;
        _nameController.text = provider.categoryById(_categoryId!)!.name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;
    final categories = provider.categories;
    final currency = provider.displayCurrency;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final limit = double.tryParse(_limitController.text) ?? 0;
    final spent = _existingBudget != null
        ? provider.toDisplayAmount(_existingBudget!.spent)
        : 0.0;
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;

    final category = _categoryId != null
        ? provider.categoryById(_categoryId!)
        : null;
    final accent = category?.color ?? AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const AppIcon(AppIcons.clear, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(isEditing ? 'Edit Budget' : 'Add Budget'),
        actions: [
          TextButton(onPressed: () => _save(context), child: const Text('Save')),
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
                      Text(
                        provider.displayCurrencyCode,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _limitController,
                        focusNode: _limitFocus,
                        onChanged: (_) => setState(() {}),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 42,
                          height: 1.08,
                          letterSpacing: -0.8,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          prefixText: '${currency.symbol} ',
                          prefixStyle: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 38,
                            color: AppColors.primary,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                      if (isEditing && limit > 0) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            color: spent > limit ? AppColors.error : accent,
                            backgroundColor: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightBackground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${provider.formatDisplay(spent)} of ${provider.formatInUserCurrency(limit)} used',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 18),
                      if (!isEditing) ...[
                        _FieldLabel('Type'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _TypeChip(
                                label: 'Monthly',
                                iconAsset: AppIcons.wallet,
                                selected: _type == BudgetFormType.monthly,
                                onTap: () =>
                                    _selectType(BudgetFormType.monthly),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _TypeChip(
                                label: 'Category',
                                iconAsset: AppIcons.category,
                                selected: _type == BudgetFormType.category,
                                onTap: () =>
                                    _selectType(BudgetFormType.category),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (_showCategoryPicker) ...[
                        _FieldLabel('Category'),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 44,
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
                                onTap: () => setState(() {
                                  _categoryId = cat.id;
                                  if (_type == BudgetFormType.category) {
                                    _nameController.text = cat.name;
                                  }
                                }),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Budget name',
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
                      _FieldLabel('Alert at'),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _alertPresets.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final preset = _alertPresets[index];
                            final label = '${(preset * 100).toInt()}%';
                            return _AlertChip(
                              label: label,
                              selected: _alertThreshold == preset,
                              warning: preset >= 0.9,
                              onTap: () =>
                                  setState(() => _alertThreshold = preset),
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
                child: Text(isEditing ? 'Update' : 'Create Budget'),
              ),
              if (isEditing) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _confirmDelete(context),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Delete Budget'),
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
        title: const Text('Delete Budget'),
        content: const Text(
          'Are you sure you want to delete this budget?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.budget);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget deleted (design only)')),
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

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _AddEditBudgetScreenState._kAnimDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.12)
            : Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(_AddEditBudgetScreenState._kChipRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(_AddEditBudgetScreenState._kChipRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                  iconAsset,
                  size: 18,
                  color: selected ? AppColors.primary : null,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
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
      duration: _AddEditBudgetScreenState._kAnimDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? category.color.withValues(alpha: 0.15)
            : Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(_AddEditBudgetScreenState._kChipRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(_AddEditBudgetScreenState._kChipRadius),
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

class _AlertChip extends StatelessWidget {
  const _AlertChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.warning = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning ? AppColors.warning : AppColors.primary;

    return AnimatedContainer(
      duration: _AddEditBudgetScreenState._kAnimDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? color.withValues(alpha: 0.12)
            : Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(
                  warning ? AppIcons.warning : AppIcons.notifications,
                  size: 16,
                  color: selected ? color : null,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? color : null,
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
