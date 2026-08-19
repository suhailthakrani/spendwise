import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/avatar_storage.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/profile_avatar.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../providers/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  var _initialized = false;
  var _submitting = false;
  var _obscure = true;
  String? _error;

  /// Current display path (existing saved avatar or newly picked).
  String? _avatarPath;

  /// True when user chose to remove avatar.
  var _clearAvatar = false;

  /// Pending new file from picker (not yet copied into app storage).
  String? _pendingSourcePath;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile() {
    final profile = ref.read(currentUserProvider).valueOrNull;
    if (profile == null || _initialized) return;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _avatarPath = profile.avatarUrl;
    _initialized = true;
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null || !mounted) return;
      setState(() {
        _pendingSourcePath = file.path;
        _avatarPath = file.path;
        _clearAvatar = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not pick image');
    }
  }

  void _showAvatarOptions() {
    final hasAvatar =
        (_avatarPath != null && _avatarPath!.trim().isNotEmpty) && !_clearAvatar;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const AppIcon(AppIcons.profile, size: 22),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAvatar(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const AppIcon(AppIcons.add, size: 22),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAvatar(ImageSource.camera);
                  },
                ),
                if (hasAvatar)
                  ListTile(
                    leading: const AppIcon(
                      AppIcons.delete,
                      size: 22,
                      color: AppColors.error,
                    ),
                    title: const Text('Remove photo'),
                    titleTextStyle: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _avatarPath = null;
                        _pendingSourcePath = null;
                        _clearAvatar = true;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      setState(() => _error = 'Not signed in');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      String? savedAvatarPath;
      if (_pendingSourcePath != null) {
        savedAvatarPath = await AvatarStorage.saveForUser(
          userId: userId,
          sourcePath: _pendingSourcePath!,
        );
      } else if (_clearAvatar) {
        await AvatarStorage.deleteForUser(userId);
      }

      final newPassword = _newPasswordController.text.trim();
      await ref.read(authControllerProvider).updateProfile(
            name: _nameController.text,
            email: _emailController.text,
            currentPassword: _currentPasswordController.text.isEmpty
                ? null
                : _currentPasswordController.text,
            newPassword: newPassword.isEmpty ? null : newPassword,
            avatarUrl: savedAvatarPath,
            clearAvatar: _clearAvatar,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        context.pop();
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not update profile');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (_, __) => _hydrateFromProfile());
    _hydrateFromProfile();

    final theme = Theme.of(context);
    final displayPath = _clearAvatar ? null : _avatarPath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        leading: SoftIconButton(
          asset: AppIcons.clear,
          onPressed: () => context.pop(),
          size: 40,
        ),
        leadingWidth: 64,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            8,
            AppSpacing.page,
            24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _submitting ? null : _showAvatarOptions,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ProfileAvatar(path: displayPath, size: 96),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: AppIcon(
                                  AppIcons.edit,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _submitting ? null : _showAvatarOptions,
                        child: const Text('Change photo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppTextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return 'Enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Enter your email';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Change password',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Leave blank to keep your current password',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 12),
                AppTextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Current password',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: AppIcon(
                        _obscure ? AppIcons.info : AppIcons.clear,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AppTextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'New password',
                    helperText: 'At least 6 characters',
                  ),
                  validator: (v) {
                    final value = v ?? '';
                    if (value.isEmpty) return null;
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
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
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _submitting ? null : _save,
                  child: Text(_submitting ? 'Saving…' : 'Save changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
