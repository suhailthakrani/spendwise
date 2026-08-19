import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _items = <({String q, String a})>[
    (
      q: 'Is my data uploaded to a server?',
      a:
          'SpendWise stores your expenses, budgets, and account locally on this device. Optional Google Drive backup writes a JSON file to your own Drive after you add that Google email. EvenLogix does not host your ledger. Crash reports and usage analytics, when enabled, do not include your password or expense amounts.',
    ),
    (
      q: 'How do I back up to Google Drive?',
      a:
          'Open You → Google Drive backup, add the Google account email, then tap Back up now. Restore any time from this page or the sign-in screen.',
    ),
    (
      q: 'Can I sign in with Face ID or fingerprint?',
      a:
          'Yes. In Settings, turn on Biometric sign-in. After you log out, the sign-in screen shows Sign in with biometrics for that local account.',
    ),
    (
      q: 'Can multiple people use SpendWise on one phone?',
      a:
          'Yes. Each person can create a local account. Data is kept separate by user. Closing an account only deletes that account’s data.',
    ),
    (
      q: 'What does Country control?',
      a:
          'Country mainly affects number and date formatting. Currency follows the country you pick until you choose a different supported currency.',
    ),
    (
      q: 'How do saving goals work?',
      a:
          'Create a goal with a target amount, optionally add a wishlist item and deadline, then log contributions as you save. Budget shows a reminder of how much to set aside this month.',
    ),
    (
      q: 'How do I export my expenses?',
      a:
          'Open You → Export Excel. Choose a timeline, preview the rows, then share the file.',
    ),
    (
      q: 'How do reminders work?',
      a:
          'In Settings you can turn on bill reminders, budget limit alerts, and saving reminders (monthly pace plus deadlines). Those are scheduled on this device. Product updates are optional push messages.',
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
