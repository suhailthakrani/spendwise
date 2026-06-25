import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/currency_display.dart';
import '../data/models/user_preferences.dart';
import 'repository_providers.dart';

final preferencesProvider = StreamProvider<UserPreferences>((ref) {
  return ref.watch(preferencesRepositoryProvider).watchPreferences();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(preferencesProvider).valueOrNull?.themeMode ??
      ThemeMode.light;
});

final displayCurrencyCodeProvider = Provider<String>((ref) {
  return ref.watch(preferencesProvider).valueOrNull?.currencyCode ?? 'USD';
});

final currencyDisplayProvider = Provider<CurrencyDisplay>((ref) {
  final code = ref.watch(displayCurrencyCodeProvider);
  return CurrencyDisplay(code);
});
