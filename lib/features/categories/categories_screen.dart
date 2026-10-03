import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
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
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add category',
        onPressed: () => showCategoryEditorSheet(context),
        child: const AppIcon(AppIcons.add, size: 24, color: Colors.white),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (categories) {
          if (categories.isEmpty) {
            return EmptyState(
              iconAsset: AppIcons.category,
              title: 'No categories yet',
              subtitle: 'Add one to start organizing spend.',
              actionLabel: 'Add category',
              onAction: () => showCategoryEditorSheet(context),
            );
          }

          final expenses = expensesAsync.valueOrNull ?? [];
          final sorted = [...categories]..sort((a, b) {
              if (a.isCustom != b.isCustom) {
                return a.isCustom ? -1 : 1;
              }
              return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            });

          final customCount = sorted.where((c) => c.isCustom).length;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: sorted.length + (customCount > 0 ? 1 : 0) + 1,
            itemBuilder: (context, index) {
              var i = index;

              if (customCount > 0) {
                if (i == 0) {
                  return _SectionLabel(
                    label: 'Yours',
                    style: theme.textTheme.labelLarge,
                  );
                }
                i -= 1;
              }

              if (i == customCount) {
                return Padding(
                  padding: EdgeInsets.only(top: customCount > 0 ? 12 : 0),
                  child: _SectionLabel(
                    label: 'Built-in',
                    style: theme.textTheme.labelLarge,
                  ),
                );
              }

              final catIndex = i > customCount ? i - 1 : i;
              final cat = sorted[catIndex];
              final catExpenses =
                  expenses.where((e) => e.categoryId == cat.id).toList();
              final total = catExpenses.fold<double>(
                0,
                (s, e) => s + currency.toDisplayAmount(e.amount),
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    onTap: () {
                      if (cat.isCustom) {
                        showCategoryEditorSheet(context, category: cat);
                      } else {
                        context.push('/categories/${cat.id}');
                      }
                    },
                    onLongPress: cat.isCustom
                        ? () => context.push('/categories/${cat.id}')
                        : null,
                    leading: AppIconBox(
                      asset: AppIcons.categoryIcon(cat.iconName),
                      color: cat.color,
                      size: 44,
                      iconSize: 20,
                    ),
                    title: Text(
                      cat.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      catExpenses.isEmpty
                          ? 'No spend yet'
                          : '${catExpenses.length} · ${currency.formatInUserCurrency(total)}',
                    ),
                    trailing: AppIcon(
                      cat.isCustom ? AppIcons.edit : AppIcons.chevronRight,
                      size: 18,
                      color: AppColors.tertiaryText(context),
                    ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.style});

  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        label,
        style: style?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryText(context),
        ),
      ),
    );
  }
}
