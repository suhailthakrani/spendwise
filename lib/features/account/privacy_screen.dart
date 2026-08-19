import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          8,
          AppSpacing.page,
          AppSpacing.navClearance,
        ),
        children: [
          Text(
            'Your privacy on SpendWise',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: August 2026',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.tertiaryText(context),
            ),
          ),
          const SizedBox(height: 20),
          const _PrivacyBlock(
            title: 'Local-first storage',
            body:
                'SpendWise is designed as an offline expense tracker. Your profile, expenses, budgets, categories, and saving goals are stored in an encrypted local database on this device.',
          ),
          const _PrivacyBlock(
            title: 'Local account',
            body:
                'SpendWise does not create an EvenLogix cloud account. Sign-in credentials are verified locally. Passwords never leave this device. Optional Google Sign-In is used only to write or read your backup file on your own Drive.',
          ),
          const _PrivacyBlock(
            title: 'Google Drive backup',
            body:
                'If you add a Google Drive email, SpendWise can save a JSON backup of your expenses, budgets, and goals to that Google account. Backups are not encrypted. Password hashes are never included. Restore any time with the same Drive email.',
          ),
          const _PrivacyBlock(
            title: 'Biometric sign-in',
            body:
                'If you enable Face ID or fingerprint, SpendWise unlocks the local account already on this device. Biometric data stays in the operating system. We never store your fingerprint or face.',
          ),
          const _PrivacyBlock(
            title: 'Crash reports and analytics',
            body:
                'If Firebase is configured, SpendWise may send anonymous crash reports and usage events (screens opened, settings toggled). We do not send your email, password, or expense amounts.',
          ),
          const _PrivacyBlock(
            title: 'Notifications',
            body:
                'Bill, budget, and goal reminders are scheduled on this device. Product updates use push messaging only if you opt in. You can change this anytime in Settings.',
          ),
          const _PrivacyBlock(
            title: 'Encryption at rest',
            body:
                'The app database is protected with SQLCipher. The encryption key is stored in the platform secure store (Keychain / Keystore), not in plain files.',
          ),
          const _PrivacyBlock(
            title: 'Exports you choose',
            body:
                'If you export Excel, files are created on this device and shared only through the system share sheet you select. We do not upload spreadsheet exports.',
          ),
          const _PrivacyBlock(
            title: 'Photos',
            body:
                'Profile photos you pick stay in app storage on this device. They are removed when you clear your avatar or close your account.',
          ),
          const _PrivacyBlock(
            title: 'Closing your account',
            body:
                'Close account (in Settings) asks for your password, then deletes only the signed-in user’s data from this device. Other local users are unaffected.',
          ),
          const _PrivacyBlock(
            title: 'Contact',
            body:
                'SpendWise is built by EvenLogix. The full public policy is at evenlogix.com/spendwise_privacy. For privacy questions, email privacy@evenlogix.com.',
          ),
        ],
      ),
    );
  }
}

class _PrivacyBlock extends StatelessWidget {
  const _PrivacyBlock({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText(context),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
