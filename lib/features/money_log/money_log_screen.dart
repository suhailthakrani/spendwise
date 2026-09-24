import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/amount_input_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/money_log.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class MoneyLogScreen extends ConsumerWidget {
  const MoneyLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(moneyLogsProvider);
    final expenses = ref.watch(expensesProvider).valueOrNull ?? [];
    final currency = ref.watch(currencyDisplayProvider);
    final now = DateTime.now();

    final monthLogs = logsAsync.maybeWhen(
      data: (logs) => MoneyLog.inMonth(logs, now),
      orElse: () => const <MoneyLog>[],
    );
    final outside = MoneyLog.total(monthLogs);
    final fromBudget = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Money log')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add log',
        onPressed: () => showMoneyLogSheet(context),
        child: const AppIcon(AppIcons.add, size: 24, color: Colors.white),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (_) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              12,
              AppSpacing.page,
              100,
            ),
            children: [
              _SummaryCard(
                monthLabel: DateFormatter.monthYear(now),
                outsideLabel: currency.format(outside),
                fromBudgetLabel: currency.format(fromBudget),
                totalLabel: currency.format(outside + fromBudget),
              ),
              const SizedBox(height: 20),
              Text(
                'This month',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              if (monthLogs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    'Nothing outside your budget yet. Use + to log an amount and a short note.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText(context),
                        ),
                  ),
                )
              else
                ...monthLogs.map(
                  (log) => _LogTile(
                    log: log,
                    amountLabel: currency.format(log.amount),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.monthLabel,
    required this.outsideLabel,
    required this.fromBudgetLabel,
    required this.totalLabel,
  });

  final String monthLabel;
  final String outsideLabel;
  final String fromBudgetLabel;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = AppColors.secondaryText(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthLabel,
              style: theme.textTheme.labelMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 6),
            Text(
              'Outside your budget',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              outsideLabel,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _Line(label: 'From budget', value: fromBudgetLabel),
            const SizedBox(height: 6),
            _Line(label: 'Outside budget', value: outsideLabel),
            const SizedBox(height: 8),
            _Line(label: 'Total spent', value: totalLabel, emphasize: true),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = emphasize
        ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)
        : theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryText(context),
          );

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}

class _LogTile extends ConsumerWidget {
  const _LogTile({required this.log, required this.amountLabel});

  final MoneyLog log;
  final String amountLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(log.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showAppConfirmDialog(
        context: context,
        title: 'Remove this log?',
        message: 'This only removes the note. Your budget is unchanged.',
        confirmLabel: 'Remove',
        iconAsset: AppIcons.delete,
      ),
      onDismissed: (_) {
        ref.read(moneyLogRepositoryProvider).delete(log.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const AppIcon(AppIcons.delete, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        title: Text(
          log.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(DateFormatter.relative(log.date)),
        trailing: Text(
          amountLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}

Future<void> showMoneyLogSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const _MoneyLogSheet(),
  );
}

class _MoneyLogSheet extends ConsumerStatefulWidget {
  const _MoneyLogSheet();

  @override
  ConsumerState<_MoneyLogSheet> createState() => _MoneyLogSheetState();
}

class _MoneyLogSheetState extends ConsumerState<_MoneyLogSheet> {
  final _amount = TextEditingController();
  final _message = TextEditingController();
  var _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final currency = ref.read(currencyDisplayProvider);
    final display = currency.parseInput(_amount.text);
    final message = _message.text.trim();
    if (display == null || display <= 0) {
      _toast('Enter an amount');
      return;
    }
    if (message.isEmpty) {
      _toast('Add a short note');
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(moneyLogRepositoryProvider);
      await repo.create(
        MoneyLog(
          id: repo.newId(),
          amount: currency.toStorageAmount(display),
          message: message,
          date: DateTime.now(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        _toast('Could not save');
      }
    }
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyDisplayProvider);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log outside budget',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'This stays out of your budget totals.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText(context),
                ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            inputFormatters: [
              AmountInputFormatter(decimalDigits: currency.decimalDigits),
            ],
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '${currency.symbol} ',
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _message,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: const InputDecoration(
              labelText: 'Note',
              hintText: 'Emergency, family, urgent work…',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Add'),
          ),
        ],
      ),
    );
  }
}
