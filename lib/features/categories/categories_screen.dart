import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/category.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final expensesAsync = ref.watch(expensesProvider);
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            tooltip: 'Add category',
            icon: const AppIcon(AppIcons.add, size: 22),
            onPressed: () => _openAddCategorySheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddCategorySheet(context),
        child: const AppIcon(AppIcons.add, size: 24, color: Colors.white),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (categories) {
          final expenses = expensesAsync.valueOrNull ?? [];

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final catExpenses =
                  expenses.where((e) => e.categoryId == cat.id).toList();
              final total = catExpenses.fold<double>(
                0,
                (s, e) => s + currency.toDisplayAmount(e.amount),
              );

              return Card(
                child: ListTile(
                  onTap: () => context.push('/categories/${cat.id}'),
                  leading: AppIconBox(
                    asset: AppIcons.categoryIcon(cat.iconName),
                    color: cat.color,
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          cat.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (cat.isCustom) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Custom',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    '${catExpenses.length} transactions · ${currency.formatInUserCurrency(total)}',
                  ),
                  trailing: AppIcon(
                    AppIcons.chevronRight,
                    size: 20,
                    color: AppColors.tertiaryText(context),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openAddCategorySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Drag-to-dismiss steals TextField cursor/selection gestures.
      enableDrag: false,
      builder: (_) => const _AddCategorySheet(),
    );
  }
}

class _AddCategorySheet extends ConsumerStatefulWidget {
  const _AddCategorySheet();

  @override
  ConsumerState<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<_AddCategorySheet> {
  static const _palette = <Color>[
    Color(0xFF0D9488),
    Color(0xFF3B82F6),
    Color(0xFF0EA5E9),
    Color(0xFFF97316),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFF6366F1),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
    Color(0xFF8B5CF6),
    Color(0xFF059669),
    Color(0xFF64748B),
  ];

  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();

  late Color _selectedColor;
  late String _selectedIcon;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = _palette.first;
    _selectedIcon = AppIcons.categoryIconChoices.last;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nameFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a category name')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(categoryRepositoryProvider);
      await repo.create(
        ExpenseCategory(
          id: repo.newId(),
          name: name,
          iconName: _selectedIcon,
          color: _selectedColor,
          isCustom: true,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$name" added')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        // Avoid the sheet parent stealing horizontal drags from the TextField.
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add custom category',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  icon: const AppIcon(AppIcons.clear, size: 20),
                ),
              ],
            ),
            Text(
              'e.g. Personal grooming, Bike maintenance, Travel',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              // Only persist when the user taps "Add category".
              onSubmitted: (_) => _nameFocus.unfocus(),
              decoration: const InputDecoration(
                labelText: 'Category name',
                hintText: 'Personal grooming',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Color',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryText(context),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final color in _palette)
                  GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? theme.colorScheme.onSurface
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Icon',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.secondaryText(context),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final iconName in AppIcons.categoryIconChoices)
                  GestureDetector(
                    onTap: () => setState(() => _selectedIcon = iconName),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _selectedIcon == iconName
                            ? _selectedColor.withValues(alpha: 0.16)
                            : AppColors.softFill(context),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                          color: _selectedIcon == iconName
                              ? _selectedColor
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: AppIcon(
                          AppIcons.categoryIcon(iconName),
                          size: 20,
                          color: _selectedColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Adding…' : 'Add category'),
            ),
          ],
        ),
      ),
    );
  }
}
