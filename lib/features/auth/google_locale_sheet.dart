import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/form_widgets.dart';
import '../../data/models/app_currency.dart';
import '../../data/models/app_region.dart';
import '../../data/models/user_profile.dart';
import '../../providers/auth_providers.dart';
import '../../providers/repository_providers.dart';

class GoogleLocaleChoice {
  const GoogleLocaleChoice({
    required this.regionCode,
    required this.currencyCode,
  });

  final String regionCode;
  final String currencyCode;
}

/// Continues with Google, then asks for country and currency when the
/// account does not already exist on this device.
Future<UserProfile?> signInWithGoogleAskingLocale(
  BuildContext context,
  WidgetRef ref,
) async {
  final identity = await ref.read(googleAuthServiceProvider).pickAccount();
  if (identity == null) return null;

  final repo = ref.read(userProfileRepositoryProvider);
  final existing = await repo.findByGoogleId(identity.id) ??
      await repo.findByEmail(identity.email);

  String? regionCode;
  String? currencyCode;
  if (existing == null) {
    if (!context.mounted) return null;
    final choice = await showGoogleLocaleSheet(context);
    if (choice == null) return null;
    regionCode = choice.regionCode;
    currencyCode = choice.currencyCode;
  }

  return ref.read(authControllerProvider).continueWithGoogle(
        identity: identity,
        regionCode: regionCode,
        currencyCode: currencyCode,
      );
}

Future<GoogleLocaleChoice?> showGoogleLocaleSheet(BuildContext context) {
  final region = AppRegion.fromDeviceLocale(
    PlatformDispatcher.instance.locale.countryCode,
  );
  return showModalBottomSheet<GoogleLocaleChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => _GoogleLocaleSheet(
      initialRegionCode: region.code,
      initialCurrencyCode: AppCurrency.byCode(region.suggestedCurrencyCode).code,
    ),
  );
}

class _GoogleLocaleSheet extends StatefulWidget {
  const _GoogleLocaleSheet({
    required this.initialRegionCode,
    required this.initialCurrencyCode,
  });

  final String initialRegionCode;
  final String initialCurrencyCode;

  @override
  State<_GoogleLocaleSheet> createState() => _GoogleLocaleSheetState();
}

class _GoogleLocaleSheetState extends State<_GoogleLocaleSheet> {
  late String _regionCode = widget.initialRegionCode;
  late String _currencyCode = widget.initialCurrencyCode;
  var _currencyManuallyChosen = false;

  Future<void> _pickCountry() async {
    final selected = await showSearchablePickerSheet<AppRegion>(
      context: context,
      title: 'Country',
      searchHint: 'Search countries',
      items: AppRegion.all,
      labelOf: (r) => r.name,
      subtitleOf: (r) => r.code,
      isSelected: (r) => r.code == _regionCode,
      iconAsset: AppIcons.globe,
    );
    if (selected == null) return;
    setState(() {
      _regionCode = selected.code;
      if (!_currencyManuallyChosen) {
        _currencyCode = AppCurrency.byCode(selected.suggestedCurrencyCode).code;
      }
    });
  }

  Future<void> _pickCurrency() async {
    final selected = await showSearchablePickerSheet<AppCurrency>(
      context: context,
      title: 'Currency',
      searchHint: 'Search currencies',
      items: AppCurrency.all,
      labelOf: (c) => c.name,
      subtitleOf: (c) => '${c.code} · ${c.symbol}',
      isSelected: (c) => c.code == _currencyCode,
      iconAsset: AppIcons.currency,
      trailingOf: (c) => c.symbol,
    );
    if (selected == null) return;
    setState(() {
      _currencyManuallyChosen = true;
      _currencyCode = selected.code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final region = AppRegion.byCode(_regionCode);
    final currency = AppCurrency.byCode(_currencyCode);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.page, 8, AppSpacing.page, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Country & currency',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Currency follows your country until you pick a different one.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText(context),
            ),
          ),
          const SizedBox(height: 20),
          FormPickerTile(
            iconAsset: AppIcons.globe,
            label: 'Country',
            value: region.name,
            onTap: _pickCountry,
          ),
          const SizedBox(height: 12),
          FormPickerTile(
            iconAsset: AppIcons.currency,
            label: 'Currency',
            value: '${currency.name} (${currency.code})',
            onTap: _pickCurrency,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softFill(context),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                const AppIcon(
                  AppIcons.currency,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Amounts will show as ${currency.symbol} in ${region.name}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              Navigator.pop(
                context,
                GoogleLocaleChoice(
                  regionCode: _regionCode,
                  currencyCode: _currencyCode,
                ),
              );
            },
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
