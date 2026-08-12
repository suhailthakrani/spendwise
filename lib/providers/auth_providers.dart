import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_profile.dart';
import '../data/repositories/user_profile_repository.dart';
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
    final profile = await _ref.read(userProfileRepositoryProvider).signUp(
          name: name,
          email: email,
          password: password,
          regionCode: regionCode,
          currencyCode: currencyCode,
        );
    await _ref.read(preferencesRepositoryProvider).completeOnboarding();
    await _ref.read(preferencesRepositoryProvider).setActiveUserId(profile.id);
    return profile;
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final profile = await _ref.read(userProfileRepositoryProvider).signIn(
          email: email,
          password: password,
        );
    await _ref.read(preferencesRepositoryProvider).setActiveUserId(profile.id);
    return profile;
  }

  Future<void> signOut() async {
    await _ref.read(preferencesRepositoryProvider).clearSession();
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
}
