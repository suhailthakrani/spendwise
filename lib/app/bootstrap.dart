import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/app_crashlytics.dart';
import '../data/services/firebase_bootstrap.dart';
import '../data/services/notification_service.dart';
import '../providers/notification_providers.dart';
import 'app.dart';

Future<void> bootstrap() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final firebaseReady = await FirebaseBootstrap.initialize();
  if (firebaseReady) {
    await AppCrashlytics.install();
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (_) {}
  }

  final notifications = NotificationService();
  await notifications.initialize();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const SpendWiseApp(),
    ),
  );
}
