import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../providers/auth_providers.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final prefsAsync = ref.watch(preferencesProvider);
    final theme = Theme.of(context);

    return prefsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('You')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('You')),
        body: Center(child: Text('Error: $error')),
      ),
      data: (_) {
        final profile = profileAsync.valueOrNull;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'You',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  8,
                  AppSpacing.page,
                  8,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        ProfileAvatar(
                          path: profile?.avatarUrl,
                          size: 64,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (profile?.name.trim().isNotEmpty ?? false)
                                    ? profile!.name
                                    : 'Your profile',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              if ((profile?.email ?? '').isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  profile!.email,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.secondaryText(context),
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Add your details anytime',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.secondaryText(context),
                                  ),
                                ),
                              ],
                              if (profile?.memberSince != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Member since ${profile!.memberSince!.year}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.tertiaryText(context),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SoftIconButton(
                          asset: AppIcons.edit,
                          onPressed: () => context.push(AppRoutes.editProfile),
                          size: 40,
                          iconSize: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const _SectionTitle(title: 'Data'),
              SurfaceGroup(
                children: [
                  SettingsTile(
                    iconAsset: AppIcons.savings,
                    title: 'Saving goals',
                    subtitle: 'Track goals and wishlist items',
                    onTap: () => context.push(AppRoutes.goals),
                  ),
                  SettingsTile(
                    iconAsset: AppIcons.category,
                    title: 'Categories',
                    subtitle: 'Manage spending categories',
                    onTap: () => context.push(AppRoutes.categories),
                  ),
                  SettingsTile(
                    iconAsset: AppIcons.repeat,
                    title: 'Recurring expenses',
                    subtitle: 'View on Budget tab',
                    onTap: () => context.go(AppRoutes.budget),
                  ),
                ],
              ),
              const _SectionTitle(title: 'Export'),
              SurfaceGroup(
                children: [
                  SettingsTile(
                    iconAsset: AppIcons.globe,
                    title: 'Google Drive backup',
                    subtitle: 'Add a Drive email. Back up and restore any time',
                    onTap: () => context.push(AppRoutes.backup),
                  ),
                  SettingsTile(
                    iconAsset: AppIcons.exportExcel,
                    title: 'Export Excel',
                    subtitle: 'Choose timeline and preview',
                    onTap: () => context.push(AppRoutes.export),
                  ),
                ],
              ),
              const _SectionTitle(title: 'App'),
              SurfaceGroup(
                children: [
                  SettingsTile(
                    iconAsset: AppIcons.settings,
                    title: 'Settings',
                    subtitle: 'Theme, notifications, locale, account',
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  SettingsTile(
                    iconAsset: AppIcons.info,
                    title: 'FAQs',
                    subtitle: 'Common questions',
                    onTap: () => context.push(AppRoutes.faq),
                  ),
                  SettingsTile(
                    iconAsset: AppIcons.receipt,
                    title: 'Privacy',
                    subtitle: 'How your data stays on this device',
                    onTap: () => context.push(AppRoutes.privacy),
                  ),
                ],
              ),
              const _SectionTitle(title: 'Session'),
              SurfaceGroup(
                children: [
                  SettingsTile(
                    iconAsset: AppIcons.logout,
                    title: 'Log out',
                    subtitle: 'Sign out of your account',
                    iconColor: AppColors.error,
                    onTap: () => _showLogoutDialog(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'SpendWise · EvenLogix',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.tertiaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'v1.0.0',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.tertiaryText(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Log out?',
      message:
          'You’ll need to sign in again to access this account on this device.',
      confirmLabel: 'Log out',
      iconAsset: AppIcons.logout,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(authControllerProvider).signOut();
    if (context.mounted) context.go(AppRoutes.signin);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.secondaryText(context),
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}
