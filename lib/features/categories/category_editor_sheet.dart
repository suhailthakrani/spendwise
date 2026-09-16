import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/category.dart';
import '../../providers/data_providers.dart';
import '../../providers/repository_providers.dart';

Future<void> showCategoryEditorSheet(
  BuildContext context, {
  ExpenseCategory? category,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    builder: (_) => CategoryEditorSheet(category: category),
  );
}

class CategoryEditorSheet extends ConsumerStatefulWidget {
  const CategoryEditorSheet({super.key, this.category});

  final ExpenseCategory? category;

  @override
  ConsumerState<CategoryEditorSheet> createState() =>
      _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends ConsumerState<CategoryEditorSheet> {
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

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.category;
    _nameController.text = existing?.name ?? '';
    _selectedColor = existing?.color ?? _palette.first;
    _selectedIcon = existing?.iconName ?? AppIcons.categoryIconChoices.last;
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
      final existing = widget.category;
      if (existing == null) {
        await repo.create(
          ExpenseCategory(
            id: repo.newId(),
            name: name,
            iconName: _selectedIcon,
            color: _selectedColor,
            isCustom: true,
          ),
        );
      } else {
        await repo.update(
          existing.copyWith(
            name: name,
            iconName: _selectedIcon,
            color: _selectedColor,
            isCustom: true,
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? '"$name" updated' : '"$name" added'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final existing = widget.category;
    if (existing == null) return;

    final expenses = ref.read(expensesProvider).valueOrNull ?? [];
    final used = expenses.where((e) => e.categoryId == existing.id).length;
    if (used > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            used == 1
                ? 'Move the 1 transaction out of this category first'
                : 'Move the $used transactions out of this category first',
          ),
        ),
      );
      return;
    }

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete ${existing.name}?',
      message: 'This custom category will be removed from this device.',
      confirmLabel: 'Delete',
      iconAsset: AppIcons.delete,
    );
    if (!confirmed) return;

    setState(() => _saving = true);
    try {
      await ref.read(categoryRepositoryProvider).delete(existing.id);
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${existing.name}" deleted')),
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _isEditing ? 'Edit category' : 'Add custom category',
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
              _isEditing
                  ? 'Update the name, color, or icon'
                  : 'e.g. Personal grooming, Bike maintenance, Travel',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameController,
              focusNode: _nameFocus,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
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
              child: Text(
                _saving
                    ? (_isEditing ? 'Saving…' : 'Adding…')
                    : (_isEditing ? 'Save changes' : 'Add category'),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving ? null : _delete,
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete category'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
