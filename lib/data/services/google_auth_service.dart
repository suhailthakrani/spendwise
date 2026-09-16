import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart' hide GoogleIdentity;

import '../models/google_identity.dart';
import '../repositories/user_profile_repository.dart';

/// Google identity for local SpendWise accounts (not Firebase Auth).
class GoogleAuthService {
  GoogleAuthService();

  /// Web OAuth client from google-services.json (`client_type` 3).
  static const serverClientId =
      '981163576593-dh5ids498re8tsl9e89d0sqhojul6t3u.apps.googleusercontent.com';

  /// iOS OAuth client from GoogleService-Info.plist.
  static const iosClientId =
      '981163576593-ao5aa4465m48rbvi4jqmlhpgbkdq4gko.apps.googleusercontent.com';

  static Future<void>? _initFuture;

  /// Must complete before any other Google Sign-In call.
  static Future<void> ensureInitialized() async {
    final existing = _initFuture;
    if (existing != null) return existing;

    final future = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
        ? GoogleSignIn.instance.initialize(
            clientId: iosClientId,
            serverClientId: serverClientId,
          )
        : GoogleSignIn.instance.initialize(
            serverClientId: serverClientId,
          );
    _initFuture = future;
    try {
      await future;
    } catch (error) {
      _initFuture = null;
      debugPrint('Google Sign-In initialize failed: $error');
      rethrow;
    }
  }

  /// Opens the Google account picker. Returns null if the user cancels.
  Future<GoogleIdentity?> pickAccount() async {
    final account = await authenticate(forceAccountPicker: true);
    if (account == null) return null;
    return _toIdentity(account);
  }

  /// Confirms the currently signed-in Google account, prompting if needed.
  Future<GoogleIdentity?> confirmAccount() async {
    final account = await authenticate();
    if (account == null) return null;
    return _toIdentity(account);
  }

  /// Interactive Google authentication. Returns null if the user cancels.
  Future<GoogleSignInAccount?> authenticate({
    String? preferEmail,
    bool forceAccountPicker = false,
  }) async {
    try {
      await ensureInitialized();
      final google = GoogleSignIn.instance;
      if (!google.supportsAuthenticate()) {
        throw AuthException(
          'Google Sign-In is not available on this device.',
        );
      }

      if (forceAccountPicker) {
        await _signOutQuietly();
        return await google.authenticate();
      }

      GoogleSignInAccount? account = await _lightweightAccount();
      final preferred = preferEmail?.trim().toLowerCase();
      if (account != null &&
          preferred != null &&
          preferred.isNotEmpty &&
          account.email.trim().toLowerCase() != preferred) {
        await _signOutQuietly();
        account = null;
      }

      return account ?? await google.authenticate();
    } on AuthException {
      rethrow;
    } catch (error) {
      if (isCancelled(error)) return null;
      throw AuthException(humanize(error));
    }
  }

  Future<void> signOut() async {
    try {
      await ensureInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Local session is already cleared; Google sign-out is best-effort.
    }
  }

  static Future<GoogleSignInAccount?> _lightweightAccount() async {
    try {
      final future = GoogleSignIn.instance.attemptLightweightAuthentication();
      if (future == null) return null;
      return await future;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _signOutQuietly() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  static GoogleIdentity _toIdentity(GoogleSignInAccount account) {
    final email = account.email.trim().toLowerCase();
    if (email.isEmpty || !email.contains('@')) {
      throw AuthException('Google did not return a valid email');
    }
    return GoogleIdentity(
      id: account.id,
      email: email,
      displayName: (account.displayName ?? '').trim(),
      photoUrl: account.photoUrl,
    );
  }

  static bool isCancelled(Object error) {
    if (error is GoogleSignInException) {
      return error.code == GoogleSignInExceptionCode.canceled;
    }
    final text = error is PlatformException
        ? '${error.code} ${error.message ?? ''}'
        : error.toString();
    final lower = text.toLowerCase();
    return lower.contains('sign_in_canceled') ||
        lower.contains('canceled') ||
        lower.contains('cancelled');
  }

  static String humanize(Object error) {
    if (error is GoogleSignInException) {
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
          return 'Google sign-in was cancelled';
        case GoogleSignInExceptionCode.interrupted:
          return 'Google Sign-In was interrupted. Try again.';
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          return 'Google Sign-In isn’t set up for this install. '
              'Reinstall the latest SpendWise build and try again.';
        case GoogleSignInExceptionCode.uiUnavailable:
          return 'Google Sign-In is not available in this build. '
              'Fully restart the app and try again.';
        case GoogleSignInExceptionCode.userMismatch:
          return 'Choose the same Google account to continue.';
        case GoogleSignInExceptionCode.unknownError:
          break;
      }
      final description = error.description?.trim();
      if (description != null && description.isNotEmpty) {
        debugPrint('Google Sign-In error: ${error.code} $description');
      }
    }

    final text = error is PlatformException
        ? '${error.code} ${error.message ?? ''}'
        : error.toString();
    final lower = text.toLowerCase();
    if (lower.contains('channel-error') ||
        lower.contains('unable to establish connection')) {
      return 'Google Sign-In is not available in this build. Fully restart the app and try again.';
    }
    if (lower.contains('network_error') || lower.contains('network')) {
      return 'Check your internet connection and try again.';
    }
    if (lower.contains('10:') ||
        lower.contains('developer_error') ||
        lower.contains('api_not_connected') ||
        lower.contains('clientconfiguration') ||
        lower.contains('serverclientid')) {
      return 'Google Sign-In isn’t set up for this install. '
          'Reinstall the latest SpendWise build and try again.';
    }
    debugPrint('Google Sign-In error: $error');
    return 'Could not continue with Google. Try again.';
  }
}
