import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart' hide GoogleIdentity;

import '../models/google_identity.dart';
import '../repositories/user_profile_repository.dart';

/// Google identity for local SpendWise accounts (not Firebase Auth).
class GoogleAuthService {
  GoogleAuthService({GoogleSignIn? client}) : _client = client;

  /// Web OAuth client from google-services.json (`client_type` 3).
  static const serverClientId =
      '981163576593-dh5ids498re8tsl9e89d0sqhojul6t3u.apps.googleusercontent.com';

  static const identityScopes = [
    'email',
    'https://www.googleapis.com/auth/userinfo.profile',
  ];

  GoogleSignIn? _client;

  GoogleSignIn get signInClient {
    return _client ??= GoogleSignIn(
      scopes: identityScopes,
      serverClientId: serverClientId,
    );
  }

  /// Opens the Google account picker. Returns null if the user cancels.
  Future<GoogleIdentity?> pickAccount() async {
    try {
      final account = await signInClient.signIn();
      if (account == null) return null;
      return _toIdentity(account);
    } on AuthException {
      rethrow;
    } catch (error) {
      if (_isCancelled(error)) return null;
      throw AuthException(_humanize(error));
    }
  }

  /// Confirms the currently signed-in Google account, prompting if needed.
  Future<GoogleIdentity?> confirmAccount() async {
    try {
      var account =
          signInClient.currentUser ?? await signInClient.signInSilently();
      account ??= await signInClient.signIn();
      if (account == null) return null;
      return _toIdentity(account);
    } on AuthException {
      rethrow;
    } catch (error) {
      if (_isCancelled(error)) return null;
      throw AuthException(_humanize(error));
    }
  }

  Future<void> signOut() async {
    try {
      await signInClient.signOut();
    } catch (_) {
      // Local session is already cleared; Google sign-out is best-effort.
    }
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

  static bool _isCancelled(Object error) {
    final text = error is PlatformException
        ? '${error.code} ${error.message ?? ''}'
        : error.toString();
    final lower = text.toLowerCase();
    return lower.contains('sign_in_canceled') || lower.contains('canceled');
  }

  static String _humanize(Object error) {
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
        lower.contains('api_not_connected')) {
      return 'Google Sign-In is not configured for this app yet.';
    }
    debugPrint('Google Sign-In error: $error');
    return 'Could not continue with Google. Try again.';
  }
}
