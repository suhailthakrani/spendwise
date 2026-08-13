import 'dart:async';
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'firebase_bootstrap.dart';

abstract final class AppCrashlytics {
  static Future<void> install() async {
    if (!FirebaseBootstrap.isReady) return;

    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(
        FirebaseCrashlytics.instance.recordFlutterFatalError(details),
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
      );
      return true;
    };

    Isolate.current.addErrorListener(
      RawReceivePort((pair) {
        final errorAndStacktrace = pair as List<dynamic>;
        unawaited(
          FirebaseCrashlytics.instance.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last is StackTrace
                ? errorAndStacktrace.last as StackTrace
                : null,
            fatal: true,
          ),
        );
      }).sendPort,
    );
  }

  static Future<void> setUserId(String? userId) async {
    if (!FirebaseBootstrap.isReady) return;
    await FirebaseCrashlytics.instance.setUserIdentifier(userId ?? '');
  }

  static Future<void> recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
  }) async {
    if (!FirebaseBootstrap.isReady) return;
    await FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
  }
}
