import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../data/providers/spendwise_data_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();
  String _query = '';
  String? _selectedCategoryId;
  ExpenseSortBy _sortBy = ExpenseSortBy.dateDesc;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;
    final results = provider.searchExpenses(
      query: _query,
      categoryId: _selectedCategoryId,
      sortBy: _sortBy,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search & Filter'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              controller: _queryController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by note...',
                prefixIcon: const AppIcon(AppIcons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const AppIcon(AppIcons.clear, size: 20),
                        onPressed: () {
                          _queryController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategoryId == null,
                    onSelected: (_) =>
                        setState(() => _selectedCategoryId = null),
                  ),
                ),
                ...provider.categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      category: cat,
                      selected: _selectedCategoryId == cat.id,
                      onTap: () => setState(() {
                        _selectedCategoryId =
                            _selectedCategoryId == cat.id ? null : cat.id;
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${results.length} results · ${provider.displayCurrencyCode}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                PopupMenuButton<ExpenseSortBy>(
                  initialValue: _sortBy,
                  onSelected: (v) => setState(() => _sortBy = v),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppIcon(AppIcons.sort, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        _sortBy.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  itemBuilder: (context) => ExpenseSortBy.values
                      .map((s) => PopupMenuItem(value: s, child: Text(s.label)))
                      .toList(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: results.isEmpty
                ? const EmptyState(
                    iconAsset: AppIcons.searchOff,
                    title: 'No matching expenses',
                    subtitle: 'Try adjusting your search or filters.',
                  )
                : ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 76),
                    itemBuilder: (context, index) {
                      final expense = results[index];
                      final category =
                          provider.categoryById(expense.categoryId)!;
                      return ExpenseTile(
                        expense: expense,
                        category: category,
                        onTap: () =>
                            context.push('/expenses/${expense.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
