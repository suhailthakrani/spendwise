import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/providers/spendwise_data_provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;
    final categories = provider.categories;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const AppIcon(AppIcons.add, size: 22),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final expenses = provider.expensesForCategory(cat.id);
          final total = expenses.fold<double>(
            0,
            (s, e) => s + provider.toDisplayAmount(e.amount),
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
                  Text(
                    cat.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
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
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Custom',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                '${expenses.length} transactions · ${provider.formatDisplay(total)}',
              ),
              trailing: const AppIcon(AppIcons.chevronRight, size: 20),
            ),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Category name',
            hintText: 'e.g. Travel',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category added (design only)')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
