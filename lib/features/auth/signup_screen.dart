import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/form_widgets.dart';
import '../../data/models/app_currency.dart';
import '../../data/models/app_region.dart';
import '../../data/repositories/user_profile_repository.dart';
import '../../providers/auth_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _pageController = PageController();
  final _step0Key = GlobalKey<FormState>();

  var _step = 0;
  var _obscurePassword = true;
  var _obscureConfirm = true;
  var _submitting = false;
  String? _error;

  var _regionCode = AppRegion.us.code;
  var _currencyCode = AppCurrency.usd.code;
  var _currencyManuallyChosen = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToStep(int step) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _step = step;
      _error = null;
    });
    await _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _next() async {
    if (_step == 0) {
      if (!(_step0Key.currentState?.validate() ?? false)) return;
      await _goToStep(1);
      return;
    }
    await _submit();
  }

  Future<void> _back() async {
    if (_submitting) return;
    if (_step == 0) {
      context.go(AppRoutes.signin);
      return;
    }
    await _goToStep(0);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(authControllerProvider).signUp(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            regionCode: _regionCode,
            currencyCode: _currencyCode,
          );
      if (mounted) context.go(AppRoutes.dashboard);
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something went wrong. Try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickCountry() async {
    final selected = await showSearchablePickerSheet(
      context: context,
      title: 'Country',
      searchHint: 'Search countries',
      items: AppRegion.all,
      labelOf: (r) => r.name,
      subtitleOf: (r) => r.code,
      isSelected: (r) => r.code == _regionCode,
      iconAsset: AppIcons.globe,
    );
    if (selected != null) {
      setState(() {
        _regionCode = selected.code;
        if (!_currencyManuallyChosen) {
          _currencyCode = AppCurrency.byCode(selected.suggestedCurrencyCode).code;
        }
      });
    }
  }

  Future<void> _pickCurrency() async {
    final selected = await showSearchablePickerSheet(
      context: context,
      title: 'Currency',
      searchHint: 'Search currencies',
      items: AppCurrency.all,
      labelOf: (c) => c.name,
      subtitleOf: (c) => '${c.code} · ${c.symbol}',
      isSelected: (c) => c.code == _currencyCode,
      iconAsset: AppIcons.currency,
      trailingOf: (c) => c.symbol,
    );
    if (selected != null) {
      setState(() {
        _currencyManuallyChosen = true;
        _currencyCode = selected.code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final region = AppRegion.byCode(_regionCode);
    final currency = AppCurrency.byCode(_currencyCode);
    final strength = _PasswordStrength.from(_passwordController.text);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF07151A),
                      Color(0xFF0A0E17),
                      Color(0xFF0F1A22),
                    ]
                  : const [
                      Color(0xFFE8F7F5),
                      Color(0xFFF1F4F8),
                      Color(0xFFEEF2F7),
                    ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: _step == 0 ? 'Back to sign in' : 'Back',
                        onPressed: _submitting ? null : _back,
                        icon: Icon(
                          _step == 0
                              ? Icons.close_rounded
                              : Icons.arrow_back_rounded,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: _StepProgress(step: _step),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_step + 1}/2',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.secondaryText(context),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AutofillGroup(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            8,
                            AppSpacing.page,
                            12,
                          ),
                          child: Form(
                            key: _step0Key,
                            child: _PersonalStep(
                              nameController: _nameController,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              confirmController: _confirmController,
                              obscurePassword: _obscurePassword,
                              obscureConfirm: _obscureConfirm,
                              enabled: !_submitting,
                              strength: strength,
                              onTogglePassword: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              onToggleConfirm: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            8,
                            AppSpacing.page,
                            12,
                          ),
                          child: _LocaleStep(
                            region: region,
                            currency: currency,
                            enabled: !_submitting,
                            onPickCountry: _pickCountry,
                            onPickCurrency: _pickCurrency,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    8,
                    AppSpacing.page,
                    12 + (bottomInset > 0 ? 0 : 4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null) ...[
                        _ErrorBanner(message: _error!),
                        const SizedBox(height: 12),
                      ],
                      FilledButton(
                        onPressed: _submitting ? null : _next,
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_step == 0 ? 'Continue' : 'Create account'),
                      ),
                      if (_step == 0)
                        TextButton(
                          onPressed: _submitting
                              ? null
                              : () => context.go(AppRoutes.signin),
                          child: Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.secondaryText(context),
                              ),
                              children: [
                                TextSpan(
                                  text: 'Sign in',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(2, (index) {
        final active = index <= step;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            height: 4,
            margin: EdgeInsets.only(right: index == 1 ? 0 : 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.full),
              color: active ? AppColors.primary : AppColors.softFill(context),
            ),
          ),
        );
      }),
    );
  }
}

class _PersonalStep extends StatelessWidget {
  const _PersonalStep({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.enabled,
    required this.strength,
    required this.onTogglePassword,
    required this.onToggleConfirm,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final bool enabled;
  final _PasswordStrength strength;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BrandHeader(
          title: 'Create account',
          subtitle: 'Your details stay on this device.',
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: nameController,
          enabled: enabled,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Alex Morgan',
            prefixIcon: Icon(Icons.person_outline_rounded, size: 22),
          ),
          validator: (v) {
            if ((v ?? '').trim().isEmpty) return 'Enter your name';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailController,
          enabled: enabled,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'you@email.com',
            prefixIcon: Icon(Icons.mail_outline_rounded, size: 22),
          ),
          validator: (v) {
            final value = v?.trim() ?? '';
            if (value.isEmpty) return 'Enter your email';
            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
            if (!ok) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: passwordController,
          enabled: enabled,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'At least 6 characters',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22),
            suffixIcon: IconButton(
              onPressed: enabled ? onTogglePassword : null,
              tooltip: obscurePassword ? 'Show password' : 'Hide password',
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 22,
              ),
            ),
          ),
          validator: (v) {
            if ((v ?? '').length < 6) return 'Use at least 6 characters';
            return null;
          },
        ),
        if (passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          _PasswordStrengthMeter(strength: strength),
        ],
        const SizedBox(height: 12),
        TextFormField(
          controller: confirmController,
          enabled: enabled,
          obscureText: obscureConfirm,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            labelText: 'Confirm password',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22),
            suffixIcon: IconButton(
              onPressed: enabled ? onToggleConfirm : null,
              tooltip: obscureConfirm ? 'Show password' : 'Hide password',
              icon: Icon(
                obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 22,
              ),
            ),
          ),
          validator: (v) {
            if (v != passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Next: choose your country and currency.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.tertiaryText(context),
          ),
        ),
      ],
    );
  }
}

class _LocaleStep extends StatelessWidget {
  const _LocaleStep({
    required this.region,
    required this.currency,
    required this.enabled,
    required this.onPickCountry,
    required this.onPickCurrency,
  });

  final AppRegion region;
  final AppCurrency currency;
  final bool enabled;
  final VoidCallback onPickCountry;
  final VoidCallback onPickCurrency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _BrandHeader(
          title: 'Country & currency',
          subtitle:
              'Currency follows your country until you pick a different one.',
        ),
        const SizedBox(height: 24),
        FormPickerTile(
          iconAsset: AppIcons.globe,
          label: 'Country',
          value: region.name,
          onTap: enabled ? onPickCountry : null,
        ),
        const SizedBox(height: 12),
        FormPickerTile(
          iconAsset: AppIcons.currency,
          label: 'Currency',
          value: '${currency.name} (${currency.code})',
          onTap: enabled ? onPickCurrency : null,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.softFill(context),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              const AppIcon(
                AppIcons.currency,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Amounts will show as ${currency.symbol} in ${region.name}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(size: 56),
        const SizedBox(height: 18),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryText(context),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PasswordStrength {
  empty,
  weak,
  fair,
  strong;

  static _PasswordStrength from(String value) {
    if (value.isEmpty) return _PasswordStrength.empty;
    var score = 0;
    if (value.length >= 6) score++;
    if (value.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[a-z]').hasMatch(value)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    if (score <= 2) return _PasswordStrength.weak;
    if (score <= 3) return _PasswordStrength.fair;
    return _PasswordStrength.strong;
  }

  double get progress => switch (this) {
        _PasswordStrength.empty => 0,
        _PasswordStrength.weak => 0.33,
        _PasswordStrength.fair => 0.66,
        _PasswordStrength.strong => 1,
      };

  String get label => switch (this) {
        _PasswordStrength.empty => '',
        _PasswordStrength.weak => 'Weak',
        _PasswordStrength.fair => 'Fair',
        _PasswordStrength.strong => 'Strong',
      };

  Color get color => switch (this) {
        _PasswordStrength.empty => AppColors.textTertiaryLight,
        _PasswordStrength.weak => AppColors.error,
        _PasswordStrength.fair => AppColors.warning,
        _PasswordStrength.strong => AppColors.success,
      };
}

class _PasswordStrengthMeter extends StatelessWidget {
  const _PasswordStrengthMeter({required this.strength});

  final _PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.full),
            child: LinearProgressIndicator(
              value: strength.progress,
              minHeight: 5,
              backgroundColor: AppColors.softFill(context),
              color: strength.color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          strength.label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: strength.color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
