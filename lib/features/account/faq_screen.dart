import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _items = <({String q, String a})>[
    (
      q: 'Is my data uploaded to a server?',
      a:
          'No. SpendWise stores your expenses, budgets, and account locally on this device. There is no cloud sync in this version.',
    ),
    (
      q: 'Can multiple people use SpendWise on one phone?',
      a:
          'Yes. Each person can create a local account. Data is kept separate by user. Closing an account only deletes that account’s data.',
    ),
    (
      q: 'What does Country control?',
      a:
          'Country mainly affects number and date formatting. Currency is separate — you can pick any display currency regardless of country.',
    ),
    (
      q: 'How do saving goals work?',
      a:
          'Create a goal with a target amount, optionally add a wishlist item and deadline, then log contributions as you save. Budget shows a reminder of how much to set aside this month.',
    ),
    (
      q: 'How do I export my expenses?',
      a:
          'Open You → Export CSV or Export Excel. Choose a timeline, preview the rows, then share the file.',
    ),
    (
      q: 'What happens if I close my account?',
      a:
          'After password confirmation, SpendWise permanently deletes that user’s expenses, budgets, goals, categories, and profile from this device. Other accounts on the device remain.',
    ),
    (
      q: 'I forgot my password. Can I reset it?',
      a:
          'Because accounts are local-only, there is no remote password reset. If you still remember the password, change it in Edit profile. Otherwise you may need to create a new local account.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('FAQs')),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          8,
          AppSpacing.page,
          AppSpacing.navClearance,
        ),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            child: Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: Text(
                  item.q,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.a,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText(context),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
