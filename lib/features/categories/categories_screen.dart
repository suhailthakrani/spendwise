import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/category.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import 'category_editor_sheet.dart';

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
            onPressed: () => showCategoryEditorSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCategoryEditorSheet(context),
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
                  trailing: cat.isCustom
                      ? _CategoryActions(category: cat)
                      : AppIcon(
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
}

class _CategoryActions extends StatelessWidget {
  const _CategoryActions({required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Category actions',
      icon: AppIcon(
        AppIcons.more,
        size: 20,
        color: AppColors.tertiaryText(context),
      ),
      onSelected: (value) {
        if (value == 'edit') {
          showCategoryEditorSheet(context, category: category);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit or delete'),
        ),
      ],
    );
  }
}
