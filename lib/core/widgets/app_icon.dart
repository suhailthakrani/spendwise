import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_spacing.dart';

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.asset, {
    super.key,
    this.size = 24,
    this.color,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final double size;
  final Color? color;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? IconTheme.of(context).color;

    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: iconColor != null
          ? ColorFilter.mode(iconColor, BlendMode.srcIn)
          : null,
      fit: fit,
    );
  }
}

class AppIconBox extends StatelessWidget {
  const AppIconBox({
    super.key,
    required this.asset,
    required this.color,
    this.size = 48,
    this.iconSize = 22,
    this.radius,
  });

  final String asset;
  final Color color;
  final double size;
  final double iconSize;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius ?? size * 0.30),
      ),
      child: Center(
        child: AppIcon(asset, size: iconSize, color: color),
      ),
    );
  }
}

/// Circular icon button used in app bars / headers.
class SoftIconButton extends StatelessWidget {
  const SoftIconButton({
    super.key,
    required this.asset,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 20,
    this.color,
  });

  final String asset;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFF0A0F1A).withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: AppIcon(asset, size: iconSize, color: color),
          ),
        ),
      ),
    );
  }
}
