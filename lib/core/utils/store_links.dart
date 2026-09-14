import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Play Store / feedback helpers for SpendWise.
abstract final class StoreLinks {
  static const packageId = 'com.evenlogix.spendwise';

  static const playStoreHttps =
      'https://play.google.com/store/apps/details?id=$packageId';

  static const playStoreMarket = 'market://details?id=$packageId';

  static const feedbackEmail = 'privacy@evenlogix.com';

  /// Opens the listing in the Play Store app when possible.
  static Future<bool> openPlayStore() async {
    final market = Uri.parse(playStoreMarket);
    final https = Uri.parse(playStoreHttps);

    // Prefer the Play Store app over a browser tab.
    try {
      final opened = await launchUrl(
        market,
        mode: LaunchMode.externalApplication,
      );
      if (opened) return true;
    } catch (_) {
      // Fall through to https / non-browser modes.
    }

    try {
      final opened = await launchUrl(
        https,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (opened) return true;
    } catch (_) {}

    if (await canLaunchUrl(https)) {
      return launchUrl(https, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Opens email compose for product feedback.
  static Future<bool> openFeedbackEmail() async {
    final subject = Uri.encodeComponent('SpendWise feedback');
    final body = Uri.encodeComponent(
      'Hi EvenLogix,\n\nHere is my feedback for SpendWise:\n\n',
    );
    final uri = Uri.parse('mailto:$feedbackEmail?subject=$subject&body=$body');
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }

  static void showLaunchError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
