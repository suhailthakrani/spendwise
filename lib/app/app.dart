import 'package:flutter/material.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../data/providers/spendwise_data_provider.dart';

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = SpendWiseDataProvider.instance;

    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'SpendWise',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: provider.preferences.themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
