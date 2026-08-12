import 'package:flutter/material.dart';

import '../constants/app_images.dart';

/// SpendWise brand logo from `assets/images/`.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 72,
    this.transparent = false,
    this.borderRadius,
  });

  final double size;
  /// Use the transparent PNG (best on dark backgrounds).
  final bool transparent;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final asset = transparent || isDark
        ? AppImages.logoTransparent
        : AppImages.logo;

    final child = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'SpendWise',
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    // Full mark already has rounded art — light clip keeps edges clean.
    if (!transparent && !isDark) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: child,
      );
    }

    return child;
  }
}
