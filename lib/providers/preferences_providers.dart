import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/currency_display.dart';
import '../data/models/user_preferences.dart';
import '../data/repositories/preferences_repository.dart';
import 'database_provider.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepository(ref.watch(databaseProvider));
});

final preferencesProvider = StreamProvider<UserPreferences>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchPreferences();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(preferencesProvider).valueOrNull?.themeMode ??
      ThemeMode.light;
});

/// Locale settings for the signed-in account (per-user).
final _activeProfileLocaleProvider =
    StreamProvider<({String currencyCode, String regionCode})>((ref) {
  final userId = ref.watch(preferencesProvider).valueOrNull?.activeUserId;
  if (userId == null || userId.isEmpty) {
    return Stream.value((currencyCode: 'USD', regionCode: 'US'));
  }

  final db = ref.watch(databaseProvider);
  return (db.select(db.userProfiles)..where((t) => t.id.equals(userId)))
      .watchSingleOrNull()
      .map((row) {
    if (row == null) return (currencyCode: 'USD', regionCode: 'US');
    return (currencyCode: row.currencyCode, regionCode: row.regionCode);
  });
});

final displayCurrencyCodeProvider = Provider<String>((ref) {
  return ref.watch(_activeProfileLocaleProvider).valueOrNull?.currencyCode ??
      'USD';
});

final displayRegionCodeProvider = Provider<String>((ref) {
  return ref.watch(_activeProfileLocaleProvider).valueOrNull?.regionCode ??
      'US';
});

final currencyDisplayProvider = Provider<CurrencyDisplay>((ref) {
  return CurrencyDisplay(
    displayCurrencyCode: ref.watch(displayCurrencyCodeProvider),
    regionCode: ref.watch(displayRegionCodeProvider),
  );
});
