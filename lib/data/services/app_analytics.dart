import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

import 'firebase_bootstrap.dart';

/// High-level product analytics. Never send email, passwords, or amounts.
class AppAnalytics {
  AppAnalytics();

  FirebaseAnalytics? get _analytics =>
      FirebaseBootstrap.isReady ? FirebaseAnalytics.instance : null;

  NavigatorObserver? get navigatorObserver =>
      _analytics == null ? null : FirebaseAnalyticsObserver(analytics: _analytics!);

  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics?.logEvent(name: name, parameters: parameters);
  }

  Future<void> logScreen(String name) async {
    await _analytics?.logScreenView(screenName: name);
  }

  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics?.setAnalyticsCollectionEnabled(enabled);
  }
}
