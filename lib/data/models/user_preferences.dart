import 'package:flutter/material.dart';

class UserPreferences {
  const UserPreferences({
    required this.themeMode,
    required this.regionCode,
    required this.currencyCode,
  });

  final ThemeMode themeMode;
  final String regionCode;
  final String currencyCode;

  factory UserPreferences.defaults() => const UserPreferences(
        themeMode: ThemeMode.light,
        regionCode: 'US',
        currencyCode: 'USD',
      );

  UserPreferences copyWith({
    ThemeMode? themeMode,
    String? regionCode,
    String? currencyCode,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      regionCode: regionCode ?? this.regionCode,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }
}
