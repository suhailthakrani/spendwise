import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../data/models/app_currency.dart';
import '../../data/models/app_region.dart';
import '../../data/providers/spendwise_data_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;
    final profile = provider.profile;
    final prefs = provider.preferences;
    final isDark = prefs.themeMode == ThemeMode.dark;

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
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
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
                              Expanded(child: Text(profile.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),),
                              IconButton(
                                onPressed: () {},
                                icon: const AppIcon(AppIcons.edit, size: 20),
                              ),
                            ],
                          ),
                          Text(profile.email),
                          if (profile.memberSince != null)
                            Text(
                              'Member since ${profile.memberSince!.year}',
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
              provider.setThemeMode(
                value ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
          SettingsTile(
            iconAsset: AppIcons.globe,
            title: 'Region',
            subtitle: provider.region.name,
            onTap: () => _showRegionPicker(context, provider),
          ),
          SettingsTile(
            iconAsset: AppIcons.currency,
            title: 'Currency',
            subtitle:
                '${AppCurrency.byCode(prefs.currencyCode).name} (${prefs.currencyCode}) · App-wide',
            onTap: () => _showCurrencyPicker(context, provider),
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
            onTap: () => _showExportSnackBar(context, 'CSV'),
          ),
          SettingsTile(
            iconAsset: AppIcons.exportExcel,
            title: 'Export to Excel',
            subtitle: 'Download all expenses as Excel',
            onTap: () => _showExportSnackBar(context, 'Excel'),
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
                const AppIcon(AppIcons.logo, size: 18, color: AppColors.primary),
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
  }

  void _showRegionPicker(BuildContext context, SpendWiseDataProvider provider) {
    _showPickerBottomSheet(
      context: context,
      title: 'Select Region',
      children: AppRegion.all.map((region) {
        final selected = provider.preferences.regionCode == region.code;
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
            provider.setRegion(region.code);
            Navigator.pop(context);
          },
        );
      }).toList(),
    );
  }

  void _showCurrencyPicker(
    BuildContext context,
    SpendWiseDataProvider provider,
  ) {
    _showPickerBottomSheet(
      context: context,
      title: 'Select Currency',
      subtitle: 'Applies to all amounts across the app',
      children: AppCurrency.all.map((currency) {
        final selected = provider.preferences.currencyCode == currency.code;
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
            provider.setCurrency(currency.code);
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
      builder: (ctx) {
        final maxListHeight = MediaQuery.sizeOf(ctx).height * 0.55;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, subtitle == null ? 8 : 4),
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
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxListHeight),
                child: ListView(
                  shrinkWrap: true,
                  children: children,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExportSnackBar(BuildContext context, String format) {
    final currency = SpendWiseDataProvider.instance.displayCurrencyCode;
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
