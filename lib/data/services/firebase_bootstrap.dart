import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Initializes Firebase when native config is present.
///
/// Run `flutterfire configure` and add `google-services.json` /
/// `GoogleService-Info.plist` before Crashlytics, Analytics, or FCM can start.
/// Local reminders still work without that config.
abstract final class FirebaseBootstrap {
  static bool _ready = false;

  static bool get isReady => _ready;

  static Future<bool> initialize() async {
    if (_ready) return true;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _ready = Firebase.apps.isNotEmpty;
    } catch (error, stackTrace) {
      debugPrint('Firebase not configured: $error');
      debugPrint('$stackTrace');
      _ready = false;
    }
    return _ready;
  }
}
