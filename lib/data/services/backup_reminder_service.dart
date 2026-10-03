import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon.dart';
import '../models/user_preferences.dart';

enum _BackupDialogChoice { backup, later, never }

/// Soft monthly dialog + helpers for weekly backup notifications.
///
/// - Dialog (monthly): when backup missing / older than 30 days
/// - Notification (weekly): scheduled by [ReminderScheduler] when older than 7 days
class BackupReminderService {
  BackupReminderService();

  static const _disabledKey = 'backup.reminder.disabled';
  static const _dialogSnoozeKey = 'backup.reminder.dialog_snooze_ms';
  static const dialogStaleDays = 30;
  static const notificationStaleDays = 7;

  final _storage = const FlutterSecureStorage();
  var _dialogShownThisSession = false;

  /// Whether a weekly local notification should be scheduled.
  static bool shouldScheduleWeeklyNotification(UserPreferences prefs) {
    if (!prefs.notificationsEnabled || !prefs.isSignedIn) return false;
    final last = prefs.lastBackupAt;
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= notificationStaleDays;
  }

  /// Next Sunday 11:00 local (or next week if that already passed).
  static DateTime nextWeeklyReminder(DateTime now) {
    final today = DateTime(now.year, now.month, now.day, 11);
    final daysUntilSunday = (DateTime.sunday - today.weekday) % 7;
    var candidate = today.add(Duration(days: daysUntilSunday));
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 7));
    }
    return candidate;
  }

  Future<void> maybePromptDialog(
    BuildContext context, {
    required UserPreferences prefs,
    required int expenseCount,
  }) async {
    if (_dialogShownThisSession) return;
    if (!prefs.isSignedIn) return;
    if (expenseCount < 3) return;

    if (await _storage.read(key: _disabledKey) == '1') return;

    final snoozeRaw = await _storage.read(key: _dialogSnoozeKey);
    if (snoozeRaw != null) {
      final snoozeMs = int.tryParse(snoozeRaw);
      if (snoozeMs != null &&
          DateTime.now().isBefore(
            DateTime.fromMillisecondsSinceEpoch(snoozeMs),
          )) {
        return;
      }
    }

    final last = prefs.lastBackupAt;
    final stale = last == null ||
        DateTime.now().difference(last).inDays >= dialogStaleDays;
    if (!stale) return;
    if (!context.mounted) return;

    _dialogShownThisSession = true;

    final choice = await showDialog<_BackupDialogChoice>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text(
            last == null ? 'Keep a Drive backup?' : 'Time for a Drive backup',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AppIcon(
                    AppIcons.savings,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                last == null
                    ? 'Save your spend history to Google Drive so you don’t lose it if this phone is reset or replaced.'
                    : 'Your last backup was over a month ago. A quick Drive backup keeps your history safe.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText(ctx),
                  height: 1.4,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, _BackupDialogChoice.never),
              child: Text(
                'Don’t remind',
                style: TextStyle(color: AppColors.tertiaryText(ctx)),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(ctx, _BackupDialogChoice.later),
                  child: const Text('Later'),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(ctx, _BackupDialogChoice.backup),
                  child: const Text('Back up'),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    switch (choice) {
      case _BackupDialogChoice.backup:
        context.push(AppRoutes.backup);
      case _BackupDialogChoice.later:
        final snoozeUntil = DateTime.now()
            .add(const Duration(days: 7))
            .millisecondsSinceEpoch;
        await _storage.write(key: _dialogSnoozeKey, value: '$snoozeUntil');
      case _BackupDialogChoice.never:
        await _storage.write(key: _disabledKey, value: '1');
      case null:
        final snoozeUntil = DateTime.now()
            .add(const Duration(days: 7))
            .millisecondsSinceEpoch;
        await _storage.write(key: _dialogSnoozeKey, value: '$snoozeUntil');
    }
  }
}
