import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
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
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) => AppConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      tone: tone,
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
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) => _AppInputDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      fieldLabel: fieldLabel,
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
    this.child,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final AppConfirmTone tone;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isDestructive = tone == AppConfirmTone.destructive;
    final accent = isDestructive ? scheme.error : scheme.primary;
    final onAccent = isDestructive ? scheme.onError : scheme.onPrimary;
    final surface = isDark ? AppColors.darkCard : AppColors.lightCard;
    final dismiss = onCancel ?? () => Navigator.pop(context, false);
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
    );
    final buttonText = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
    );

    return Dialog(
      elevation: 0,
      backgroundColor: surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xxl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: dismiss,
                  tooltip: 'Close',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.tertiaryText(context),
                    minimumSize: const Size(36, 36),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: -0.2,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Text(
                  message,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ),
              if (child != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: child,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      OutlinedButton(
                        onPressed: dismiss,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.onSurface,
                          backgroundColor: surface,
                          side: BorderSide(color: AppColors.border(context)),
                          minimumSize: const Size(80, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: buttonShape,
                          textStyle: buttonText,
                        ),
                        child: Text(cancelLabel),
                      ),
                      FilledButton(
                        onPressed: onConfirm,
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: onAccent,
                          elevation: 0,
                          minimumSize: const Size(80, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: buttonShape,
                          textStyle: buttonText,
                        ),
                        child: Text(confirmLabel),
                      ),
                    ],
                  ),
                ),
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
    this.validator,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final String fieldLabel;
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
