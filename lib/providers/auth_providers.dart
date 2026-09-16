import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/avatar_storage.dart';
import '../data/models/app_currency.dart';
import '../data/models/app_region.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/user_profile_repository.dart';
import '../data/services/app_crashlytics.dart';
import '../data/services/firebase_auth_service.dart';
import 'preferences_providers.dart';
import 'repository_providers.dart';

/// Active session user id from preferences (null when signed out).
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(preferencesProvider).valueOrNull?.activeUserId;
});

final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(preferencesProvider).valueOrNull?.isSignedIn ?? false;
});

final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(preferencesProvider).valueOrNull?.hasCompletedOnboarding ??
      false;
});

/// Signed-in profile stream; empty when no session.
final currentUserProvider = StreamProvider<UserProfile?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null || userId.isEmpty) {
    return Stream.value(null);
  }
  return ref.watch(userProfileRepositoryProvider).watchById(userId);
});

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  Future<void> completeOnboarding() async {
    await _ref.read(preferencesRepositoryProvider).completeOnboarding();
  }

  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
    required String regionCode,
    required String currencyCode,
  }) async {
    final repo = _ref.read(userProfileRepositoryProvider);
    final existing = await repo.findByEmail(email);
    if (existing != null) {
      throw AuthException('An account with this email already exists');
    }

    final cloud = await _ref.read(firebaseAuthServiceProvider).tryCreateEmailAccount(
          email: email.trim().toLowerCase(),
          password: password,
        );
    switch (cloud) {
      case FirebaseEmailOutcome.emailTaken:
        throw AuthException(
          'An account with this email already exists. Sign in instead.',
        );
      case FirebaseEmailOutcome.invalidEmail:
        throw AuthException('Enter a valid email');
      case FirebaseEmailOutcome.weakPassword:
        throw AuthException('Password must be at least 6 characters');
      case FirebaseEmailOutcome.created:
      case FirebaseEmailOutcome.signedIn:
      case FirebaseEmailOutcome.offline:
      case FirebaseEmailOutcome.failed:
        break;
    }

    final profile = await repo.signUp(
      name: name,
      email: email,
      password: password,
      regionCode: regionCode,
      currencyCode: currencyCode,
    );
    await _ref.read(preferencesRepositoryProvider).completeOnboarding();
    await _ref.read(preferencesRepositoryProvider).setActiveUserId(profile.id);
    await AppCrashlytics.setUserId(profile.id);
    return profile;
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final repo = _ref.read(userProfileRepositoryProvider);
    try {
      final profile = await repo.signIn(
        email: email,
        password: password,
      );
      await _ref.read(firebaseAuthServiceProvider).trySignInEmail(
            email: email.trim().toLowerCase(),
            password: password,
          );
      await _ref.read(preferencesRepositoryProvider).setActiveUserId(profile.id);
      await AppCrashlytics.setUserId(profile.id);
      return profile;
    } on AuthException {
      final local = await repo.findByEmail(email);
      if (local != null) rethrow;

      final cloud = await _ref.read(firebaseAuthServiceProvider).trySignInEmail(
            email: email.trim().toLowerCase(),
            password: password,
          );
      if (cloud != FirebaseEmailOutcome.signedIn) rethrow;

      final region = AppRegion.fromDeviceLocale(
        PlatformDispatcher.instance.locale.countryCode,
      );
      final profile = await repo.signUp(
        name: email.trim().split('@').first,
        email: email,
        password: password,
        regionCode: region.code,
        currencyCode: AppCurrency.byCode(region.suggestedCurrencyCode).code,
      );
      await _ref.read(preferencesRepositoryProvider).completeOnboarding();
      await _ref.read(preferencesRepositoryProvider).setActiveUserId(profile.id);
      await AppCrashlytics.setUserId(profile.id);
      return profile;
    }
  }

  /// Signs in or creates a local profile from a Google account.
  /// Returns null when the user cancels the Google picker.
  Future<UserProfile?> continueWithGoogle({
    String? regionCode,
    String? currencyCode,
  }) async {
    final identity = await _ref.read(googleAuthServiceProvider).pickAccount();
    if (identity == null) return null;

    final region = AppRegion.fromDeviceLocale(
      regionCode ?? PlatformDispatcher.instance.locale.countryCode,
    );
    final currency = AppCurrency.byCode(
      currencyCode ?? region.suggestedCurrencyCode,
    );

    final profile =
        await _ref.read(userProfileRepositoryProvider).signInOrSignUpWithGoogle(
              identity: identity,
              regionCode: region.code,
              currencyCode: currency.code,
            );
    await _ref.read(preferencesRepositoryProvider).completeOnboarding();
    await _ref.read(preferencesRepositoryProvider).setActiveUserId(profile.id);
    await AppCrashlytics.setUserId(profile.id);
    return profile;
  }

  Future<void> signOut() async {
    await _ref.read(preferencesRepositoryProvider).clearSession();
    await _ref.read(googleAuthServiceProvider).signOut();
    await _ref.read(firebaseAuthServiceProvider).signOut();
    await AppCrashlytics.setUserId(null);
  }

  Future<void> signInWithBiometrics() async {
    final prefs =
        await _ref.read(preferencesRepositoryProvider).getPreferences();
    if (!prefs.canUnlockWithBiometrics) {
      throw AuthException('Biometric sign-in is off');
    }
    final userId = prefs.biometricUserId!;
    final profile =
        await _ref.read(userProfileRepositoryProvider).getById(userId);
    if (profile == null) {
      await _ref.read(preferencesRepositoryProvider).setBiometricUnlock(
            enabled: false,
          );
      throw AuthException('That account is no longer on this device');
    }

    final biometric = _ref.read(biometricAuthServiceProvider);
    final label = await biometric.label();
    final ok = await biometric.authenticate(
      reason: 'Sign in to SpendWise with $label',
    );
    if (!ok) {
      throw AuthException('Biometric sign-in cancelled');
    }

    await _ref.read(preferencesRepositoryProvider).setActiveUserId(userId);
    await AppCrashlytics.setUserId(userId);
  }

  Future<void> setBiometricUnlock({required bool enabled}) async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) {
      throw AuthException('Not signed in');
    }

    final biometric = _ref.read(biometricAuthServiceProvider);
    if (enabled) {
      final available = await biometric.isAvailable();
      if (!available) {
        throw AuthException(
            'Set up Face ID or a fingerprint in device settings first');
      }
      final label = await biometric.label();
      final ok = await biometric.authenticate(
        reason: 'Enable $label for SpendWise',
      );
      if (!ok) {
        throw AuthException('Biometric confirmation cancelled');
      }
    }

    await _ref.read(preferencesRepositoryProvider).setBiometricUnlock(
          enabled: enabled,
          userId: userId,
        );
  }

  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    String? currentPassword,
    String? newPassword,
    String? avatarUrl,
    bool clearAvatar = false,
  }) async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) {
      throw AuthException('Not signed in');
    }
    return _ref.read(userProfileRepositoryProvider).updateProfile(
          userId: userId,
          name: name,
          email: email,
          currentPassword: currentPassword,
          newPassword: newPassword,
          avatarUrl: avatarUrl,
          clearAvatar: clearAvatar,
        );
  }

  Future<UserProfile> setRegion(String regionCode) async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) throw AuthException('Not signed in');
    return _ref.read(userProfileRepositoryProvider).setRegion(
          userId: userId,
          regionCode: regionCode,
        );
  }

  Future<UserProfile> setCurrency(String currencyCode) async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) throw AuthException('Not signed in');
    return _ref.read(userProfileRepositoryProvider).setCurrency(
          userId: userId,
          currencyCode: currencyCode,
        );
  }

  /// Password-gated deletion of the signed-in user's local data only.
  Future<void> closeAccount({String? password}) async {
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) throw AuthException('Not signed in');

    final profile =
        await _ref.read(userProfileRepositoryProvider).getById(userId);
    if (profile == null) throw AuthException('Account not found');

    if (profile.hasLocalPassword) {
      if (password == null || password.isEmpty) {
        throw AuthException('Enter your password');
      }
      await _ref.read(userProfileRepositoryProvider).deleteAccount(
            userId: userId,
            password: password,
          );
    } else {
      final identity =
          await _ref.read(googleAuthServiceProvider).confirmAccount();
      if (identity == null) {
        throw AuthException('Google confirmation cancelled');
      }
      final sameAccount = identity.email == profile.email ||
          (profile.googleId != null && identity.id == profile.googleId);
      if (!sameAccount) {
        throw AuthException('Confirm with the same Google account');
      }
      await _ref.read(userProfileRepositoryProvider).deleteGoogleAccount(
            userId: userId,
          );
    }

    await AvatarStorage.deleteForUser(userId);
    await _ref.read(preferencesRepositoryProvider).setBiometricUnlock(
          enabled: false,
        );
    await _ref.read(preferencesRepositoryProvider).clearSession();
    await _ref.read(googleAuthServiceProvider).signOut();
    await _ref.read(firebaseAuthServiceProvider).signOut();
    await AppCrashlytics.setUserId(null);
  }
}
