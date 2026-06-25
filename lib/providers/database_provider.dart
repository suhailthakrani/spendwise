import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';

/// Singleton Drift database instance. Lives for the app session.
final databaseProvider = Provider<AppDatabase>((ref) {
  ref.keepAlive();
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});
