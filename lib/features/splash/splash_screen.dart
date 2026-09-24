import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_logo.dart';
import '../../providers/database_provider.dart';
import '../../providers/preferences_providers.dart';

/// Branded splash shown while local prefs / secure DB warm up.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _minVisible = Duration(milliseconds: 1200);
  static const _bootTimeout = Duration(seconds: 8);
  static const _splashBg = Color(0xFF041B1F);

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  var _booting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot({bool retry = false}) async {
    if (_booting) return;
    _booting = true;
    FlutterNativeSplash.remove();

    if (retry) {
      // Recreate the DB handle — a failed open/migrate can leave a dead instance.
      ref.invalidate(databaseProvider);
      ref.invalidate(preferencesProvider);
    }

    if (mounted) {
      setState(() => _error = null);
    }

    final started = DateTime.now();
    Object? bootError;
    try {
      await ref.read(preferencesProvider.future).timeout(_bootTimeout);
    } on TimeoutException catch (error, stackTrace) {
      bootError = error;
      debugPrint('Splash boot timed out: $error\n$stackTrace');
    } catch (error, stackTrace) {
      bootError = error;
      debugPrint('Splash boot failed: $error\n$stackTrace');
    }

    final elapsed = DateTime.now().difference(started);
    final remaining = _minVisible - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    if (!mounted) {
      _booting = false;
      return;
    }

    final prefs = ref.read(preferencesProvider).valueOrNull;
    if (prefs == null && bootError != null) {
      _booting = false;
      setState(() {
        _error =
            'Could not open your local data. Check storage and try again.';
      });
      return;
    }

    _booting = false;
    if (prefs == null || !prefs.hasCompletedOnboarding) {
      context.go(AppRoutes.onboarding);
    } else if (!prefs.isSignedIn) {
      context.go(AppRoutes.signin);
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayStyle(Brightness.dark),
      child: Scaffold(
        backgroundColor: _splashBg,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF06303A),
                Color(0xFF041B1F),
                Color(0xFF031416),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(
                          size: 112,
                          transparent: true,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'SpendWise',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Spend with intention',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primaryLight
                                        .withValues(alpha: 0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 28),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => _boot(retry: true),
                            child: const Text('Try again'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
