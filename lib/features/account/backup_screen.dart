import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_text_field.dart';
import '../../data/models/backup_snapshot.dart';
import '../../data/services/backup_service.dart';
import '../../data/services/google_drive_backup_client.dart';
import '../../providers/auth_providers.dart';
import '../../providers/preferences_providers.dart';
import '../../providers/repository_providers.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key, this.restoreOnly = false});

  final bool restoreOnly;

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _emailController = TextEditingController();
  final _emailKey = GlobalKey<FormState>();
  var _busy = false;
  String? _error;
  String? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(preferencesProvider).valueOrNull;
      final profile = ref.read(currentUserProvider).valueOrNull;
      final existing = prefs?.backupDriveEmail ?? profile?.email ?? '';
      if (existing.isNotEmpty && _emailController.text.isEmpty) {
        _emailController.text = existing;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String get _email => _emailController.text.trim().toLowerCase();

  Future<void> _connectDrive() async {
    setState(() {
      _busy = true;
      _error = null;
      _status = 'Choose your Google account…';
    });
    try {
      final typed = _email;
      final email =
          await ref.read(googleDriveBackupClientProvider).connectAccount(
                preferEmail: typed.isEmpty ? null : typed,
              );
      _emailController.text = email;
      await ref.read(preferencesRepositoryProvider).setBackupDriveEmail(email);
      if (mounted) {
        setState(() => _status = 'Connected to Google Drive ($email)');
      }
    } on DriveBackupException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _backupNow() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      setState(() => _error = 'Sign in to back up this account');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _status = 'Saving to Google Drive…';
    });

    try {
      if (_email.isEmpty) {
        final email =
            await ref.read(googleDriveBackupClientProvider).connectAccount();
        _emailController.text = email;
        await ref
            .read(preferencesRepositoryProvider)
            .setBackupDriveEmail(email);
      }

      final snapshot = await ref.read(backupServiceProvider).createSnapshot(
            userId: userId,
            driveEmail: _email,
          );
      final prefs = ref.read(preferencesProvider).valueOrNull;
      final result = await ref.read(googleDriveBackupClientProvider).upload(
            snapshot: snapshot,
            expectedEmail: _email,
            existingFileId: prefs?.backupDriveFileId,
          );
      await ref.read(preferencesRepositoryProvider).setLastBackup(
            at: DateTime.now(),
            driveFileId: result.fileId,
          );
      if (mounted) {
        setState(
            () => _status = 'Backup saved to Google Drive (${result.email})');
      }
    } on DriveBackupException catch (error) {
      if (!mounted) return;
      if (!error.signInUnavailable) {
        setState(() => _error = error.message);
        return;
      }
      setState(
        () => _status = 'Choose Google Drive in the save location list.',
      );
      final saved = await _saveViaDrivePicker(userId);
      if (!mounted) return;
      if (saved) {
        setState(() {
          _error = null;
          _status = 'Backup saved to the folder you picked.';
        });
      } else {
        setState(() => _error = error.message);
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// System save sheet (Files / Drive), not the share sheet.
  Future<bool> _saveViaDrivePicker(String userId) async {
    final snapshot = await ref.read(backupServiceProvider).createSnapshot(
          userId: userId,
          driveEmail: _email.isEmpty ? null : _email,
        );
    final bytes =
        Uint8List.fromList(utf8.encode(jsonEncode(snapshot.toJson())));
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save SpendWise backup',
      fileName: 'spendwise_backup.json',
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: bytes,
    );
    if (path == null) return false;
    await ref.read(preferencesRepositoryProvider).setLastBackup(
          at: DateTime.now(),
        );
    return true;
  }

  Future<void> _restoreFromDrive() async {
    final confirmed = await _confirmRestore();
    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _error = null;
      _status = 'Looking up backup on Google Drive…';
    });

    try {
      if (_email.isEmpty) {
        final email =
            await ref.read(googleDriveBackupClientProvider).connectAccount();
        _emailController.text = email;
        await ref
            .read(preferencesRepositoryProvider)
            .setBackupDriveEmail(email);
      }
      final prefs = ref.read(preferencesProvider).valueOrNull;
      final snapshot = await ref.read(googleDriveBackupClientProvider).download(
            expectedEmail: _email,
            fileId: prefs?.backupDriveFileId,
          );
      await _applySnapshot(snapshot);
    } on DriveBackupException catch (error) {
      if (!mounted) return;
      if (!error.signInUnavailable) {
        setState(() => _error = error.message);
        return;
      }
      setState(
        () => _status = 'Choose spendwise_backup.json from Google Drive.',
      );
      final restored = await _pickAndRestoreBackup();
      if (!mounted) return;
      if (!restored) {
        setState(() => _error = error.message);
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreFromFile() async {
    setState(() {
      _busy = true;
      _error = null;
      _status = 'Choose a SpendWise backup file…';
    });
    try {
      final restored = await _pickAndRestoreBackup();
      if (!mounted) return;
      if (!restored && _status != null) {
        setState(() => _status = null);
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _pickAndRestoreBackup() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return false;

    final file = picked.files.first;
    final bytes = file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null) {
      throw BackupException('Could not read the selected file');
    }
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map) {
      throw BackupException('Backup file is not valid JSON');
    }
    final snapshot = BackupSnapshot.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
    await _applySnapshot(snapshot);
    return true;
  }

  Future<void> _applySnapshot(BackupSnapshot snapshot) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId != null) {
      await ref.read(backupServiceProvider).restoreIntoUser(
            snapshot: snapshot,
            targetUserId: currentUserId,
          );
      if (mounted) {
        setState(() => _status = 'Backup restored on this device');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored')),
        );
      }
      return;
    }

    final password = await _askRestorePassword();
    if (password == null || password.isEmpty) return;

    final userId = await ref.read(backupServiceProvider).restoreAsAccount(
          snapshot: snapshot,
          password: password,
        );
    await ref.read(preferencesRepositoryProvider).completeOnboarding();
    await ref.read(preferencesRepositoryProvider).setActiveUserId(userId);
    await ref.read(preferencesRepositoryProvider).setBackupDriveEmail(_email);
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  Future<bool?> _confirmRestore() {
    return showAppConfirmDialog(
      context: context,
      title: 'Restore backup?',
      message: widget.restoreOnly
          ? 'This creates or updates a local account from the Google Drive backup${_email.isEmpty ? '' : ' for $_email'}.'
          : 'This replaces expenses, budgets, goals, and categories on this device with the Drive backup. Your local password is kept.',
      confirmLabel: 'Restore',
      tone: AppConfirmTone.primary,
      iconAsset: AppIcons.globe,
    );
  }

  Future<String?> _askRestorePassword() {
    return showAppInputDialog(
      context: context,
      title: 'Set a local password',
      message:
          'This backup will be restored as a new account on this device. Choose a password to sign in next time.',
      confirmLabel: 'Continue',
      fieldLabel: 'Password (min 6 characters)',
      iconAsset: AppIcons.profile,
      validator: (value) {
        if (value.length < 6) return 'Use at least 6 characters';
        return null;
      },
    );
  }

  void _backToSignIn() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.signin);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(preferencesProvider).valueOrNull;
    final lastBackup = prefs?.lastBackupAt;
    final dateFmt = DateFormat('d MMM yyyy, h:mm a');

    return PopScope(
      canPop: !widget.restoreOnly || context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !widget.restoreOnly) return;
        context.go(AppRoutes.signin);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.restoreOnly ? 'Restore backup' : 'Google Drive backup',
          ),
          leading: widget.restoreOnly
              ? IconButton(
                  tooltip: 'Back to sign in',
                  onPressed: _backToSignIn,
                  icon: const Icon(Icons.arrow_back_rounded),
                )
              : null,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            8,
            AppSpacing.page,
            AppSpacing.navClearance,
          ),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const AppIconBox(
                      asset: AppIcons.globe,
                      color: AppColors.primary,
                      size: 48,
                      iconSize: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Google Drive',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Connect your Google account, then back up. Restore any time.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.secondaryText(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _emailKey,
              child: AppTextFormField(
                controller: _emailController,
                enabled: !_busy,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Google Drive email',
                  hintText: 'you@gmail.com',
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return null;
                  if (!email.contains('@') || !email.contains('.')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _connectDrive(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _busy ? null : _connectDrive,
              child: const Text('Connect Google Drive'),
            ),
            if (lastBackup != null) ...[
              const SizedBox(height: 16),
              Text(
                'Last backup: ${dateFmt.format(lastBackup.toLocal())}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText(context),
                ),
              ),
            ],
            if (_status != null) ...[
              const SizedBox(height: 12),
              Text(
                _status!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (!widget.restoreOnly)
              FilledButton.icon(
                onPressed: _busy ? null : _backupNow,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : AppIcon(
                        AppIcons.globe,
                        size: 18,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                label: Text(_busy ? 'Working…' : 'Back up now'),
              ),
            if (!widget.restoreOnly) const SizedBox(height: 10),
            FilledButton.tonal(
              onPressed: _busy ? null : _restoreFromDrive,
              child: const Text('Restore from Google Drive'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : _restoreFromFile,
              child: const Text('Restore from a backup file'),
            ),
          ],
        ),
      ),
    );
  }
}
