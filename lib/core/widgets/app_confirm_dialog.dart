import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_icon.dart';
import 'app_text_field.dart';

enum AppConfirmTone { primary, destructive }

Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  AppConfirmTone tone = AppConfirmTone.destructive,
  String? iconAsset,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.52),
    builder: (ctx) => AppConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      tone: tone,
      iconAsset: iconAsset,
      onCancel: () => Navigator.pop(ctx, false),
      onConfirm: () => Navigator.pop(ctx, true),
    ),
  );
  return confirmed ?? false;
}

Future<String?> showAppInputDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String fieldLabel,
  String cancelLabel = 'Cancel',
  String? iconAsset,
  bool obscureText = true,
  String? Function(String value)? validator,
}) {
  return showDialog<String>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.52),
    builder: (ctx) => _AppInputDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      fieldLabel: fieldLabel,
      iconAsset: iconAsset,
      obscureText: obscureText,
      validator: validator,
    ),
  );
}

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.tone = AppConfirmTone.destructive,
    this.iconAsset,
    this.child,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final AppConfirmTone tone;
  final String? iconAsset;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = switch (tone) {
      AppConfirmTone.destructive => AppColors.error,
      AppConfirmTone.primary => AppColors.primary,
    };
    final icon = iconAsset ??
        (tone == AppConfirmTone.destructive ? AppIcons.warning : AppIcons.info);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AppIcon(icon, size: 28, color: accent),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText(context),
                  height: 1.45,
                ),
              ),
              if (child != null) ...[
                const SizedBox(height: 18),
                child!,
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onConfirm,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(confirmLabel),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onCancel ?? () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  foregroundColor: AppColors.secondaryText(context),
                ),
                child: Text(cancelLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppInputDialog extends StatefulWidget {
  const _AppInputDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.fieldLabel,
    required this.obscureText,
    this.iconAsset,
    this.validator,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final String fieldLabel;
  final String? iconAsset;
  final bool obscureText;
  final String? Function(String value)? validator;

  @override
  State<_AppInputDialog> createState() => _AppInputDialogState();
}

class _AppInputDialogState extends State<_AppInputDialog> {
  final _controller = TextEditingController();
  late var _obscure = widget.obscureText;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text;
    final error = widget.validator?.call(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AppConfirmDialog(
      title: widget.title,
      message: widget.message,
      confirmLabel: widget.confirmLabel,
      cancelLabel: widget.cancelLabel,
      tone: AppConfirmTone.primary,
      iconAsset: widget.iconAsset ?? AppIcons.info,
      onCancel: () => Navigator.pop(context),
      onConfirm: _submit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _controller,
            obscureText: _obscure,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            autofillHints:
                widget.obscureText ? const [AutofillHints.newPassword] : null,
            decoration: InputDecoration(
              labelText: widget.fieldLabel,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 22,
                      ),
                    )
                  : null,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
