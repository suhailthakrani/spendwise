import 'package:flutter/material.dart';

import 'app.dart';

/// App entry setup. Add packages only when wiring the layer they support:
/// - flutter_riverpod → ProviderScope + providers
/// - drift + sqlite3_flutter_libs → local database
/// - path_provider + share_plus → export
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const SpendWiseApp());
}
