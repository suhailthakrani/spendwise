import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/app_currency.dart';
import '../../data/models/app_region.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final prefsAsync = ref.watch(preferencesProvider);
    final currencyCode = ref.watch(displayCurrencyCodeProvider);
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
      data: (prefs) {
        final profile = profileAsync.valueOrNull;
        final isDark = prefs.themeMode == ThemeMode.dark;
        final region = AppRegion.byCode(prefs.regionCode);

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
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.2),
                                AppColors.primaryLight.withValues(alpha: 0.25),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: AppIcon(
                              AppIcons.profile,
                              size: 30,
                              color: AppColors.primary,
                            ),
                          ),
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
                          onPressed: () {},
                          size: 40,
                          iconSize: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const _SectionTitle(title: 'Preferences'),
              SurfaceGroup(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    secondary: AppIconBox(
                      asset: isDark ? AppIcons.darkMode : AppIcons.lightMode,
                      color: AppColors.primary,
                      size: 42,
                      iconSize: 20,
                    ),
                    title: Text(
                      'Dark mode',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Match your preference',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText(context),
                      ),
                    ),
                    value: isDark,
                    onChanged: (value) {
                      ref.read(preferencesRepositoryProvider).setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                  ),
                  SettingsTile(
                    iconAsset: AppIcons.globe,
                    title: 'Region',
                    subtitle: region.name,
                    onTap: () =>
                        _showRegionPicker(context, ref, prefs.regionCode),
                  ),
                  SettingsTile(
                    iconAsset: AppIcons.currency,
                    title: 'Currency',
                    subtitle:
                        '${AppCurrency.byCode(prefs.currencyCode).name} (${prefs.currencyCode})',
                    onTap: () =>
                        _showCurrencyPicker(context, ref, prefs.currencyCode),
                  ),
                ],
              ),
              const _SectionTitle(title: 'Data'),
              SurfaceGroup(
                children: [
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
                    iconAsset: AppIcons.exportCsv,
                    title: 'Export CSV',
                    subtitle: 'Download all expenses',
                    onTap: () =>
                        _showExportSnackBar(context, 'CSV', currencyCode),
                  ),
                  SettingsTile(
                    iconAsset: AppIcons.exportExcel,
                    title: 'Export Excel',
                    subtitle: 'Download all expenses',
                    onTap: () =>
                        _showExportSnackBar(context, 'Excel', currencyCode),
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
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppIcon(
                      AppIcons.logo,
                      size: 16,
                      color: AppColors.primary,
                    ),
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

  void _showRegionPicker(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) {
    _showPickerBottomSheet(
      context: context,
      title: 'Select region',
      children: AppRegion.all.map((region) {
        final selected = currentCode == region.code;
        return ListTile(
          leading: AppIcon(
            AppIcons.globe,
            color: selected ? AppColors.primary : null,
          ),
          title: Text(region.name),
          subtitle: Text(region.defaultCurrencyCode),
          trailing: selected
              ? const AppIcon(AppIcons.info, color: AppColors.primary)
              : null,
          onTap: () {
            ref.read(preferencesRepositoryProvider).setRegion(region.code);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  void _showCurrencyPicker(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) {
    _showPickerBottomSheet(
      context: context,
      title: 'Select currency',
      subtitle: 'Applies to all amounts across the app',
      children: AppCurrency.all.map((currency) {
        final selected = currentCode == currency.code;
        return ListTile(
          leading: AppIconBox(
            asset: AppIcons.currency,
            color: selected ? AppColors.primary : AppColors.accent,
            size: 40,
            iconSize: 20,
          ),
          title: Text(currency.name),
          subtitle: Text(currency.code),
          trailing: Text(
            currency.symbol,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : null,
                ),
          ),
          onTap: () {
            ref.read(preferencesRepositoryProvider).setCurrency(currency.code);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  void _showPickerBottomSheet({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) {
        final maxSheetHeight = MediaQuery.sizeOf(ctx).height * 0.85;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    subtitle == null ? 12 : 4,
                  ),
                  child: Text(
                    title,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      subtitle,
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText(ctx),
                          ),
                    ),
                  ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: children,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExportSnackBar(
    BuildContext context,
    String format,
    String currency,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export to $format in $currency (coming soon)'),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out (design only)')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
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
