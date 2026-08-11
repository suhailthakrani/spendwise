import 'package:flutter/material.dart';

/// SpendWise brand palette — premium fintech teal on cool neutrals.
abstract final class AppColors {
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFF2DD4BF);
  static const Color primaryMuted = Color(0xFFCCFBF1);
  static const Color accent = Color(0xFFF59E0B);

  static const Color success = Color(0xFF059669);
  static const Color error = Color(0xFFE11D48);
  static const Color warning = Color(0xFFD97706);

  /// Cool slate canvas — avoids flat white and warm cream defaults.
  static const Color lightBackground = Color(0xFFF1F4F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);

  static const Color darkBackground = Color(0xFF0A0E17);
  static const Color darkSurface = Color(0xFF141B28);
  static const Color darkCard = Color(0xFF1A2332);
  static const Color darkBorder = Color(0xFF2A3447);

  static const Color textPrimaryLight = Color(0xFF0A0F1A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  static const List<Color> chartPalette = [
    Color(0xFF0D9488),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFFE11D48),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];

  static Color secondaryText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? textSecondaryDark : textSecondaryLight;
  }

  static Color tertiaryText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? textTertiaryDark : textTertiaryLight;
  }

  static Color border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkBorder : lightBorder;
  }

  static Color softFill(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFF0A0F1A).withValues(alpha: 0.04);
  }
}
