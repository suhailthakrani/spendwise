import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firebase_bootstrap.dart';

enum FirebaseEmailOutcome {
  created,
  signedIn,
  emailTaken,
  invalidEmail,
  weakPassword,
  offline,
  failed,
}

/// Best-effort Firebase Auth for email accounts.
/// SpendWise stays usable offline if this step fails.
class FirebaseAuthService {
  FirebaseAuth? get _auth {
    if (!FirebaseBootstrap.isReady) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  Future<FirebaseEmailOutcome> tryCreateEmailAccount({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) return FirebaseEmailOutcome.offline;

    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return FirebaseEmailOutcome.created;
    } on FirebaseAuthException catch (error) {
      debugPrint('Firebase signup: ${error.code}');
      return switch (error.code) {
        'email-already-in-use' => FirebaseEmailOutcome.emailTaken,
        'invalid-email' => FirebaseEmailOutcome.invalidEmail,
        'weak-password' => FirebaseEmailOutcome.weakPassword,
        _ => FirebaseEmailOutcome.offline,
      };
    } catch (error) {
      debugPrint('Firebase signup fallback: $error');
      return FirebaseEmailOutcome.offline;
    }
  }

  Future<FirebaseEmailOutcome> trySignInEmail({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    if (auth == null) return FirebaseEmailOutcome.offline;

    try {
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return FirebaseEmailOutcome.signedIn;
    } on FirebaseAuthException catch (error) {
      debugPrint('Firebase sign-in: ${error.code}');
      return switch (error.code) {
        'invalid-email' => FirebaseEmailOutcome.invalidEmail,
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' ||
        'user-disabled' =>
          FirebaseEmailOutcome.failed,
        _ => FirebaseEmailOutcome.offline,
      };
    } catch (error) {
      debugPrint('Firebase sign-in fallback: $error');
      return FirebaseEmailOutcome.offline;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth?.signOut();
    } catch (_) {}
  }
}
