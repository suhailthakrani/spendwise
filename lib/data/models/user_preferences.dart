import 'package:flutter/material.dart';

class UserPreferences {
  const UserPreferences({
    required this.themeMode,
    this.hasCompletedOnboarding = false,
    this.activeUserId,
  });

  final ThemeMode themeMode;
  final bool hasCompletedOnboarding;
  final String? activeUserId;

  bool get isSignedIn =>
      activeUserId != null && activeUserId!.trim().isNotEmpty;

  factory UserPreferences.defaults() => const UserPreferences(
        themeMode: ThemeMode.light,
      );

  UserPreferences copyWith({
    ThemeMode? themeMode,
    bool? hasCompletedOnboarding,
    String? activeUserId,
    bool clearActiveUserId = false,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      activeUserId:
          clearActiveUserId ? null : (activeUserId ?? this.activeUserId),
    );
  }
}
