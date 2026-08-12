import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/amount_input_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_icon.dart';
import '../../data/models/goal_status.dart';
import '../../data/models/saving_goal.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class AddEditGoalScreen extends ConsumerStatefulWidget {
  const AddEditGoalScreen({super.key, this.goalId});

  final String? goalId;

  @override
  ConsumerState<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends ConsumerState<AddEditGoalScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _monthlyController = TextEditingController();
  final _wishlistTitleController = TextEditingController();
  final _wishlistNoteController = TextEditingController();

  DateTime? _deadline;
  bool _hasWishlist = false;
  bool _initialized = false;
  bool _saving = false;
  SavingGoal? _existing;

  bool get isEditing => widget.goalId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final currency = ref.read(currencyDisplayProvider);
    if (widget.goalId != null) {
      final goal =
          await ref.read(savingGoalRepositoryProvider).getById(widget.goalId!);
      if (!mounted) return;
      _existing = goal;
      if (goal != null) {
        _nameController.text = goal.name;
        _targetController.text = currency.formatForInput(goal.targetAmount);
        if (goal.monthlyTarget != null) {
          _monthlyController.text =
              currency.formatForInput(goal.monthlyTarget!);
        }
        _deadline = goal.deadline;
        _hasWishlist = goal.hasWishlist;
        _wishlistTitleController.text = goal.wishlistTitle ?? '';
        _wishlistNoteController.text = goal.wishlistNote ?? '';
      }
    }
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _monthlyController.dispose();
    _wishlistTitleController.dispose();
    _wishlistNoteController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime(now.year, now.month + 3, now.day),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null) return;
    setState(() => _deadline = picked);
  }

  Future<void> _save() async {
    final currency = ref.read(currencyDisplayProvider);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a goal name')),
      );
      return;
    }

    final targetDisplay = currency.parseInput(_targetController.text);
    if (targetDisplay == null || targetDisplay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid target amount')),
      );
      return;
    }

    double? monthlyStorage;
    final monthlyRaw = _monthlyController.text.trim();
    if (monthlyRaw.isNotEmpty) {
      final monthlyDisplay = currency.parseInput(monthlyRaw);
      if (monthlyDisplay == null || monthlyDisplay < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid monthly target')),
        );
        return;
      }
      if (monthlyDisplay > 0) {
        monthlyStorage = currency.toStorageAmount(monthlyDisplay);
      }
    }

    String? wishlistTitle;
    String? wishlistNote;
    if (_hasWishlist) {
      wishlistTitle = _wishlistTitleController.text.trim();
      if (wishlistTitle.isEmpty) wishlistTitle = name;
      final note = _wishlistNoteController.text.trim();
      wishlistNote = note.isEmpty ? null : note;
    }

    setState(() => _saving = true);
    final repo = ref.read(savingGoalRepositoryProvider);
    final now = DateTime.now();

    try {
      if (isEditing && _existing != null) {
        await repo.update(
          _existing!.copyWith(
            name: name,
            targetAmount: currency.toStorageAmount(targetDisplay),
            deadline: _deadline,
            monthlyTarget: monthlyStorage,
            wishlistTitle: wishlistTitle,
            wishlistNote: wishlistNote,
            clearDeadline: _deadline == null,
            clearMonthlyTarget: monthlyStorage == null,
            clearWishlistTitle: !_hasWishlist,
            clearWishlistNote: !_hasWishlist || wishlistNote == null,
            updatedAt: now,
          ),
        );
      } else {
        await repo.create(
          SavingGoal(
            id: repo.newId(),
            name: name,
            targetAmount: currency.toStorageAmount(targetDisplay),
            savedAmount: 0,
            deadline: _deadline,
            monthlyTarget: monthlyStorage,
            wishlistTitle: wishlistTitle,
            wishlistNote: wishlistNote,
            priority: 0,
            status: GoalStatus.active,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
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
    final theme = Theme.of(context);
    final currency = ref.watch(currencyDisplayProvider);

    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit goal' : 'New goal'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          8,
          AppSpacing.page,
          AppSpacing.navClearance,
        ),
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Goal name',
              hintText: 'Emergency fund',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.numberWithOptions(
              decimal: currency.allowsDecimalInput,
            ),
            inputFormatters: [
              AmountInputFormatter(decimalDigits: currency.decimalDigits),
            ],
            decoration: InputDecoration(
              labelText: 'Target amount (${currency.displayCurrencyCode})',
              hintText: currency.amountInputHint,
              prefixText: '${currency.symbol} ',
            ),
          ),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const AppIconBox(
              asset: AppIcons.calendar,
              color: AppColors.primary,
              size: 42,
              iconSize: 20,
            ),
            title: Text(
              _deadline == null
                  ? 'Deadline (optional)'
                  : 'By ${DateFormatter.short(_deadline!)}',
            ),
            subtitle: const Text('Used to pace monthly savings'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_deadline != null)
                  IconButton(
                    tooltip: 'Clear',
                    onPressed: () => setState(() => _deadline = null),
                    icon: const AppIcon(AppIcons.clear, size: 18),
                  ),
                const AppIcon(AppIcons.chevronRight, size: 18),
              ],
            ),
            onTap: _pickDeadline,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _monthlyController,
            keyboardType: TextInputType.numberWithOptions(
              decimal: currency.allowsDecimalInput,
            ),
            inputFormatters: [
              AmountInputFormatter(decimalDigits: currency.decimalDigits),
            ],
            decoration: InputDecoration(
              labelText: 'Monthly save (optional)',
              hintText: 'Overrides deadline pace',
              prefixText: '${currency.symbol} ',
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const AppIconBox(
              asset: AppIcons.shoppingBag,
              color: AppColors.accent,
              size: 42,
              iconSize: 20,
            ),
            title: const Text('Wishlist item'),
            subtitle: Text(
              'Link a product or wish to this goal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
              ),
            ),
            value: _hasWishlist,
            onChanged: (v) => setState(() => _hasWishlist = v),
          ),
          if (_hasWishlist) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _wishlistTitleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Item name',
                hintText: 'New laptop',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _wishlistNoteController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'Store, model, link…',
              ),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : (isEditing ? 'Save changes' : 'Create goal')),
          ),
        ],
      ),
    );
  }
}
