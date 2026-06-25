import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
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

    return prefsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: Center(child: Text('Error: $error')),
      ),
      data: (prefs) {
        final profile = profileAsync.valueOrNull;
        final isDark = prefs.themeMode == ThemeMode.dark;
        final region = AppRegion.byCode(prefs.regionCode);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Account'),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const AppIcon(AppIcons.settings, size: 22),
              ),
            ],
          ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.12),
                          child: const AppIcon(
                            AppIcons.profile,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      profile?.name ?? 'User',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const AppIcon(AppIcons.edit, size: 20),
                                  ),
                                ],
                              ),
                              Text(profile?.email ?? ''),
                              if (profile?.memberSince != null)
                                Text(
                                  'Member since ${profile!.memberSince!.year}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const _SectionTitle(title: 'Preferences'),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                secondary: AppIconBox(
                  asset: isDark ? AppIcons.darkMode : AppIcons.lightMode,
                  color: AppColors.primary,
                  size: 40,
                  iconSize: 20,
                ),
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
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
                onTap: () => _showRegionPicker(context, ref, prefs.regionCode),
              ),
              SettingsTile(
                iconAsset: AppIcons.currency,
                title: 'Currency',
                subtitle:
                    '${AppCurrency.byCode(prefs.currencyCode).name} (${prefs.currencyCode}) · App-wide',
                onTap: () =>
                    _showCurrencyPicker(context, ref, prefs.currencyCode),
              ),
              const Divider(indent: 20, endIndent: 20),
              const _SectionTitle(title: 'Data'),
              SettingsTile(
                iconAsset: AppIcons.category,
                title: 'Manage Categories',
                onTap: () => context.push(AppRoutes.categories),
              ),
              SettingsTile(
                iconAsset: AppIcons.repeat,
                title: 'Recurring Expenses',
                onTap: () => context.go(AppRoutes.budget),
              ),
              const Divider(indent: 20, endIndent: 20),
              const _SectionTitle(title: 'Export'),
              SettingsTile(
                iconAsset: AppIcons.exportCsv,
                title: 'Export to CSV',
                subtitle: 'Download all expenses as CSV',
                onTap: () => _showExportSnackBar(context, 'CSV', currencyCode),
              ),
              SettingsTile(
                iconAsset: AppIcons.exportExcel,
                title: 'Export to Excel',
                subtitle: 'Download all expenses as Excel',
                onTap: () => _showExportSnackBar(context, 'Excel', currencyCode),
              ),
              const Divider(indent: 20, endIndent: 20),
              const _SectionTitle(title: 'Session'),
              SettingsTile(
                iconAsset: AppIcons.logout,
                title: 'Log Out',
                subtitle: 'Sign out of your account',
                iconColor: AppColors.error,
                onTap: () => _showLogoutDialog(context),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppIcon(
                      AppIcons.logo,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SpendWise v1.0.0 · com.evenlogix.spendwise',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
      title: 'Select Region',
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
      title: 'Select Currency',
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
            style: Theme.of(context).textTheme.titleMedium,
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
                    16,
                    12,
                    16,
                    subtitle == null ? 8 : 4,
                  ),
                  child: Text(
                    title,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      subtitle,
                      style: Theme.of(ctx).textTheme.bodySmall,
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
        content: Text(
          'Export to $format in $currency (design only)',
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
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
            child: const Text('Log Out'),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
      ),
    );
  }
}
