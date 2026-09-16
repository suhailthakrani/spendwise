import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/app_icons.dart';
import '../../core/utils/store_links.dart';
import '../../core/widgets/app_confirm_dialog.dart';

/// Occasional, non-nagging Play Store rating prompt.
class RatingPromptService {
  RatingPromptService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _firstSeenKey = 'rating.first_seen_ms';
  static const _sessionsKey = 'rating.sessions';
  static const _lastPromptKey = 'rating.last_prompt_ms';
  static const _countKey = 'rating.prompt_count';
  static const _outcomeKey = 'rating.outcome';

  static const _minExpenses = 5;
  static const _minSessions = 2;
  static const _minDaysBeforeFirst = 2;
  static const _laterCooldown = Duration(days: 14);
  static const _maxPrompts = 3;

  static var _sessionCounted = false;
  static var _promptedThisSession = false;

  final FlutterSecureStorage _storage;

  Future<void> maybePrompt(
    BuildContext context, {
    required int expenseCount,
  }) async {
    if (_promptedThisSession || !context.mounted) return;
    if (expenseCount < _minExpenses) {
      await _ensureFirstSeen();
      await _bumpSession();
      return;
    }

    await _ensureFirstSeen();
    final sessions = await _bumpSession();
    final outcome = await _storage.read(key: _outcomeKey) ?? 'none';
    if (outcome == 'rated' || outcome == 'declined') return;
    if (sessions < _minSessions) return;

    final firstSeenMs = int.tryParse(
          await _storage.read(key: _firstSeenKey) ?? '',
        ) ??
        DateTime.now().millisecondsSinceEpoch;
    final firstSeen = DateTime.fromMillisecondsSinceEpoch(firstSeenMs);
    final oldEnough = DateTime.now().difference(firstSeen) >=
        const Duration(days: _minDaysBeforeFirst);
    if (!oldEnough && expenseCount < 8) return;

    final promptCount =
        int.tryParse(await _storage.read(key: _countKey) ?? '0') ?? 0;
    if (promptCount >= _maxPrompts) return;

    if (outcome == 'later') {
      final lastMs = int.tryParse(
            await _storage.read(key: _lastPromptKey) ?? '',
          ) ??
          0;
      final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
      if (DateTime.now().difference(last) < _laterCooldown) return;
    }

    _promptedThisSession = true;
    if (!context.mounted) return;
    await _show(context, promptCount);
  }

  Future<void> _show(BuildContext context, int promptCount) async {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: _lastPromptKey, value: now);
    await _storage.write(key: _countKey, value: '${promptCount + 1}');

    if (!context.mounted) return;
    final rate = await showAppConfirmDialog(
      context: context,
      title: 'Enjoying SpendWise?',
      message:
          'If it’s helping you track spending, a quick Play Store rating makes it easier for others to find.',
      confirmLabel: 'Rate SpendWise',
      cancelLabel: 'Later',
      tone: AppConfirmTone.primary,
      iconAsset: AppIcons.heart,
    );

    if (rate) {
      await _storage.write(key: _outcomeKey, value: 'rated');
      final opened = await StoreLinks.openPlayStore();
      if (!opened && context.mounted) {
        StoreLinks.showLaunchError(context, 'Could not open the Play Store');
      }
      return;
    }

    await _storage.write(key: _outcomeKey, value: 'later');
  }

  Future<void> _ensureFirstSeen() async {
    final existing = await _storage.read(key: _firstSeenKey);
    if (existing != null && existing.isNotEmpty) return;
    await _storage.write(
      key: _firstSeenKey,
      value: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  Future<int> _bumpSession() async {
    final current =
        int.tryParse(await _storage.read(key: _sessionsKey) ?? '0') ?? 0;
    if (_sessionCounted) return current;
    _sessionCounted = true;
    final next = current + 1;
    await _storage.write(key: _sessionsKey, value: '$next');
    return next;
  }
}
