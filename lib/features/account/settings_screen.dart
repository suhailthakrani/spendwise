import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/form_widgets.dart';
import '../../data/models/app_currency.dart';
import '../../data/models/app_region.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../providers/auth_providers.dart';
import '../../providers/data_providers.dart';
import '../../providers/preferences_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(preferencesProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final currencyCode = ref.watch(displayCurrencyCodeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (prefs) {
          final isDark = prefs.themeMode == ThemeMode.dark;
          final regionCode = profile?.regionCode ?? 'US';
          final currencyCodeValue = profile?.currencyCode ?? currencyCode;
          final region = AppRegion.byCode(regionCode);
          final currency = AppCurrency.byCode(currencyCodeValue);

          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.navClearance),
            children: [
              const _SectionTitle(title: 'Appearance'),
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
                      isDark ? 'On' : 'Off',
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
                ],
              ),
              const _SectionTitle(title: 'Locale'),
              SurfaceGroup(
                children: [
                  SettingsTile(
                    iconAsset: AppIcons.globe,
                    title: 'Country',
                    subtitle: region.name,
                    onTap: () => _pickCountry(context, ref, regionCode),
                  ),
                  SettingsTile(
                    iconAsset: AppIcons.currency,
                    title: 'Currency',
                    subtitle: '${currency.name} (${currency.code})',
                    onTap: () =>
                        _pickCurrency(context, ref, currencyCodeValue),
                  ),
                ],
              ),
              const _SectionTitle(title: 'Danger zone'),
              SurfaceGroup(
                children: [
                  SettingsTile(
                    iconAsset: AppIcons.delete,
                    title: 'Close account',
                    subtitle: 'Delete this account and its data on this device',
                    iconColor: AppColors.error,
                    onTap: () => _confirmCloseAccount(context),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Closing your account removes only the signed-in user’s data. Other local accounts on this device are not affected.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.tertiaryText(context),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickCountry(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) async {
    final selected = await showSearchablePickerSheet<AppRegion>(
      context: context,
      title: 'Country',
      searchHint: 'Search countries',
      items: AppRegion.all,
      labelOf: (r) => r.name,
      subtitleOf: (r) => r.code,
      isSelected: (r) => r.code == currentCode,
      iconAsset: AppIcons.globe,
    );
    if (selected != null) {
      await ref.read(authControllerProvider).setRegion(selected.code);
    }
  }

  Future<void> _pickCurrency(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) async {
    final selected = await showSearchablePickerSheet<AppCurrency>(
      context: context,
      title: 'Currency',
      searchHint: 'Search currencies',
      items: AppCurrency.all,
      labelOf: (c) => c.name,
      subtitleOf: (c) => c.code,
      isSelected: (c) => c.code == currentCode,
      iconAsset: AppIcons.currency,
      trailingOf: (c) => c.symbol,
    );
    if (selected != null) {
      await ref.read(authControllerProvider).setCurrency(selected.code);
    }
  }

  Future<void> _confirmCloseAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close account?'),
        content: const Text(
          'This permanently deletes this account’s expenses, budgets, goals, and profile on this device. Other accounts on this phone are not affected.\n\nYou’ll need to enter your password next.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _CloseAccountSheet(),
    );
  }
}

class _CloseAccountSheet extends ConsumerStatefulWidget {
  const _CloseAccountSheet();

  @override
  ConsumerState<_CloseAccountSheet> createState() => _CloseAccountSheetState();
}

class _CloseAccountSheetState extends ConsumerState<_CloseAccountSheet> {
  final _passwordController = TextEditingController();
  var _obscure = true;
  var _submitting = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _error = 'Enter your password');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider).closeAccount(password: password);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      context.go(AppRoutes.signin);
      messenger.showSnackBar(
        const SnackBar(content: Text('Account closed')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'Could not close account. Try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Close account',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'This permanently deletes your expenses, budgets, goals, and profile on this device. Enter your password to confirm.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText(context),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            enabled: !_submitting,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22),
              suffixIcon: IconButton(
                onPressed: _submitting
                    ? null
                    : () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : const Text('Delete my account'),
          ),
          TextButton(
            onPressed: _submitting ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
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
