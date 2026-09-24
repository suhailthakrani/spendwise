import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/amount_input_formatter.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../../data/models/ledger_entry_type.dart';
import '../../data/models/payment_method.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';
import 'quick_add_logic.dart';

Future<void> showBulkEntrySheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const _BulkEntrySheet(),
  );
}

class _BulkRow {
  _BulkRow({required this.amount, required this.categoryId});

  final TextEditingController amount;
  String categoryId;

  void dispose() => amount.dispose();
}

class _BulkEntrySheet extends ConsumerStatefulWidget {
  const _BulkEntrySheet();

  @override
  ConsumerState<_BulkEntrySheet> createState() => _BulkEntrySheetState();
}

class _BulkEntrySheetState extends ConsumerState<_BulkEntrySheet> {
  final _rows = <_BulkRow>[];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final prefs = ref.read(preferencesProvider).valueOrNull;
    final ranked = ref.read(categoriesByUsageProvider);
    final categoryId = QuickAddLogic.resolveCategoryId(
      rankedCategoryIds: ranked.map((c) => c.id).toList(),
      lastUsedCategoryId: prefs?.lastUsedCategoryId,
      defaultCategoryId: prefs?.defaultCategoryId,
    );

    if (!mounted || categoryId == null) return;
    setState(() {
      _rows.add(
        _BulkRow(
          amount: TextEditingController(),
          categoryId: categoryId,
        ),
      );
    });
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow(List<ExpenseCategory> categories) {
    final fallback = categories.isNotEmpty
        ? categories.first.id
        : (_rows.isNotEmpty ? _rows.last.categoryId : '');
    if (fallback.isEmpty) return;
    setState(() {
      _rows.add(
        _BulkRow(
          amount: TextEditingController(),
          categoryId: _rows.isNotEmpty ? _rows.last.categoryId : fallback,
        ),
      );
    });
  }

  Future<void> _saveAll() async {
    if (_saving) return;
    final currency = ref.read(currencyDisplayProvider);

    final entries = <({double amount, String categoryId})>[];
    for (final row in _rows) {
      final amount = currency.parseInput(row.amount.text);
      if (amount == null || amount <= 0) continue;
      entries.add((amount: amount, categoryId: row.categoryId));
    }

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one amount')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(expenseRepositoryProvider);
      String? lastCategory;
      for (final entry in entries) {
        await repo.create(
          Expense(
            id: repo.newId(),
            amount: currency.toStorageAmount(entry.amount),
            categoryId: entry.categoryId,
            note: 'Expense',
            date: DateTime.now(),
            paymentMethod: PaymentMethod.cash,
            type: LedgerEntryType.expense,
          ),
        );
        lastCategory = entry.categoryId;
      }
      if (lastCategory != null) {
        await ref
            .read(preferencesRepositoryProvider)
            .setLastUsedCategoryId(lastCategory);
      }
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${entries.length} expenses saved')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesByUsageProvider);
    final currency = ref.watch(currencyDisplayProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.page,
        right: AppSpacing.page,
        bottom: MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.viewPaddingOf(context).bottom +
            12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bulk entry',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final row = _rows[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        controller: row.amount,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: currency.allowsDecimalInput,
                        ),
                        inputFormatters: [
                          AmountInputFormatter(
                            decimalDigits: currency.decimalDigits,
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: currency.amountInputHint,
                          prefixText: '${currency.symbol} ',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: categories.any((c) => c.id == row.categoryId)
                            ? row.categoryId
                            : null,
                        items: [
                          for (final cat in categories)
                            DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            ),
                        ],
                        onChanged: (id) {
                          if (id == null) return;
                          setState(() => row.categoryId = id);
                        },
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _addRow(categories),
            child: const Text('Add another'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _saving ? null : _saveAll,
            child: Text(_saving ? 'Saving…' : 'Save all'),
          ),
        ],
      ),
    );
  }
}
