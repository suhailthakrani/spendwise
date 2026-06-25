import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/utils/category_lookup.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/expense_widgets.dart';
import '../../data/models/expense.dart';
import '../../data/models/expense_sort.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _queryController = TextEditingController();
  String _query = '';
  String? _selectedCategoryId;
  ExpenseSortBy _sortBy = ExpenseSortBy.dateDesc;
  late Future<List<Expense>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = _runSearch();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<List<Expense>> _runSearch() {
    final currency = ref.read(currencyDisplayProvider);
    return ref.read(expenseRepositoryProvider).search(
          query: _query,
          categoryId: _selectedCategoryId,
          sortBy: _sortBy,
          toDisplayAmount: currency.toDisplayAmount,
        );
  }

  void _refreshSearch() {
    setState(() => _searchFuture = _runSearch());
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final currencyCode = ref.watch(displayCurrencyCodeProvider);
    final categories = categoriesAsync.valueOrNull ?? [];

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
              onChanged: (v) {
                _query = v;
                _refreshSearch();
              },
              decoration: InputDecoration(
                hintText: 'Search by note...',
                prefixIcon: const AppIcon(AppIcons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const AppIcon(AppIcons.clear, size: 20),
                        onPressed: () {
                          _queryController.clear();
                          _query = '';
                          _refreshSearch();
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
                    onSelected: (_) {
                      _selectedCategoryId = null;
                      _refreshSearch();
                    },
                  ),
                ),
                ...categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryChip(
                      category: cat,
                      selected: _selectedCategoryId == cat.id,
                      onTap: () {
                        _selectedCategoryId =
                            _selectedCategoryId == cat.id ? null : cat.id;
                        _refreshSearch();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: FutureBuilder<List<Expense>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Row(
                  children: [
                    Text(
                      '$count results · $currencyCode',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    PopupMenuButton<ExpenseSortBy>(
                      initialValue: _sortBy,
                      onSelected: (v) {
                        _sortBy = v;
                        _refreshSearch();
                      },
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
                          .map(
                            (s) => PopupMenuItem(
                              value: s,
                              child: Text(s.label),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Expense>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = snapshot.data ?? [];
                if (results.isEmpty) {
                  return const EmptyState(
                    iconAsset: AppIcons.searchOff,
                    title: 'No matching expenses',
                    subtitle: 'Try adjusting your search or filters.',
                  );
                }

                return ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 76),
                  itemBuilder: (context, index) {
                    final expense = results[index];
                    final category =
                        categoryById(categories, expense.categoryId);
                    if (category == null) return const SizedBox.shrink();
                    return ExpenseTile(
                      expense: expense,
                      category: category,
                      onTap: () => context.push('/expenses/${expense.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
