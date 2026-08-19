import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/amount_input_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/saving_contribution.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class ContributeGoalScreen extends ConsumerStatefulWidget {
  const ContributeGoalScreen({super.key, required this.goalId});

  final String goalId;

  @override
  ConsumerState<ContributeGoalScreen> createState() =>
      _ContributeGoalScreenState();
}

class _ContributeGoalScreenState extends ConsumerState<ContributeGoalScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _save() async {
    final currency = ref.read(currencyDisplayProvider);
    final display = currency.parseInput(_amountController.text);
    if (display == null || display <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(savingGoalRepositoryProvider);
    try {
      await repo.addContribution(
        SavingContribution(
          id: repo.newId(),
          goalId: widget.goalId,
          amount: currency.toStorageAmount(display),
          note: _noteController.text.trim(),
          date: _date,
          createdAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencyDisplayProvider);
    final goalAsync = ref.watch(savingGoalDetailProvider(widget.goalId));
    final goalName = goalAsync.valueOrNull?.name ?? 'goal';

    return Scaffold(
      appBar: AppBar(title: const Text('Log savings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          8,
          AppSpacing.page,
          AppSpacing.navClearance,
        ),
        children: [
          Text(
            'Add to $goalName',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _amountController,
            autofocus: true,
            keyboardType: TextInputType.numberWithOptions(
              decimal: currency.allowsDecimalInput,
            ),
            inputFormatters: [
              AmountInputFormatter(decimalDigits: currency.decimalDigits),
            ],
            decoration: InputDecoration(
              labelText: 'Amount (${currency.displayCurrencyCode})',
              hintText: currency.amountInputHint,
              prefixText: '${currency.symbol} ',
            ),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _noteController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const AppIconBox(
              asset: AppIcons.calendar,
              color: AppColors.primary,
              size: 42,
              iconSize: 20,
            ),
            title: Text(
              '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
            ),
            subtitle: const Text('Contribution date'),
            trailing: const AppIcon(AppIcons.chevronRight, size: 18),
            onTap: _pickDate,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Add contribution'),
          ),
        ],
      ),
    );
  }
}
