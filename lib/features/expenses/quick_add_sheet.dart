import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/expense.dart';
import '../../data/models/ledger_entry_type.dart';
import '../../data/models/payment_method.dart';
import '../../data/models/transaction_template.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';
import 'quick_add_logic.dart';

Future<void> showQuickAddSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const _QuickAddSheet(),
  );
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  const _QuickAddSheet();

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  String _amountText = '';
  String? _categoryId;
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

    if (!mounted) return;
    setState(() {
      _categoryId = categoryId;
    });
  }

  void _onKey(String key) {
    final currency = ref.read(currencyDisplayProvider);
    HapticFeedback.selectionClick();
    setState(() {
      _amountText = QuickAddLogic.applyKey(
        _amountText,
        key,
        decimalDigits: currency.decimalDigits,
      );
    });
  }

  void _applyTemplate(TransactionTemplate template) {
    final currency = ref.read(currencyDisplayProvider);
    HapticFeedback.selectionClick();
    setState(() {
      _amountText = currency.formatForInput(template.amount);
      _categoryId = template.categoryId;
    });
  }

  Future<void> _toggleFavourite(TransactionTemplate template) async {
    await ref.read(templateRepositoryProvider).update(
          template.copyWith(isFavourite: !template.isFavourite),
        );
  }

  Future<void> _save() async {
    if (_saving) return;
    final currency = ref.read(currencyDisplayProvider);
    final amountDisplay = currency.parseInput(_amountText);
    if (amountDisplay == null || amountDisplay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount')),
      );
      return;
    }
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a category')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(expenseRepositoryProvider);
      await repo.create(
        Expense(
          id: repo.newId(),
          amount: currency.toStorageAmount(amountDisplay),
          categoryId: _categoryId!,
          note: 'Expense',
          date: DateTime.now(),
          paymentMethod: PaymentMethod.cash,
          type: LedgerEntryType.expense,
        ),
      );

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved')),
      );
      Navigator.of(context).pop();
      ref
          .read(preferencesRepositoryProvider)
          .setLastUsedCategoryId(_categoryId!);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyDisplayProvider);
    final categories = ref.watch(categoriesByUsageProvider);
    final templates = ref.watch(templatesProvider).valueOrNull ?? [];
    final theme = Theme.of(context);
    final displayText = _amountText.isEmpty
        ? '${currency.symbol}${currency.amountInputHint}'
        : '${currency.symbol}$_amountText';

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.page,
        right: AppSpacing.page,
        bottom: MediaQuery.viewPaddingOf(context).bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quick add',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            displayText,
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 40,
              height: 1.05,
              letterSpacing: -0.5,
              color: _amountText.isEmpty
                  ? AppColors.tertiaryText(context)
                  : null,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          if (templates.isNotEmpty) ...[
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final t = templates[index];
                  return GestureDetector(
                    onLongPress: () => _toggleFavourite(t),
                    child: ActionChip(
                      avatar: t.isFavourite
                          ? const AppIcon(
                              AppIcons.heart,
                              size: 14,
                              color: AppColors.primary,
                            )
                          : null,
                      label: Text(t.name),
                      onPressed: () => _applyTemplate(t),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final selected = cat.id == _categoryId;
                return FilterChip(
                  selected: selected,
                  label: Text(cat.name),
                  avatar: AppIcon(
                    AppIcons.categoryIcon(cat.iconName),
                    size: 16,
                    color: cat.color,
                  ),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    setState(() => _categoryId = cat.id);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _NumericKeypad(onKey: _onKey),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push(AppRoutes.addExpense);
            },
            child: const Text('More options'),
          ),
        ],
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['.', '0', 'backspace'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (final key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Material(
                        color: AppColors.softFill(context),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        child: InkWell(
                          onTap: () => onKey(key),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          child: SizedBox(
                            height: 52,
                            child: Center(
                              child: key == 'backspace'
                                  ? const AppIcon(AppIcons.clear, size: 22)
                                  : Text(
                                      key,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
