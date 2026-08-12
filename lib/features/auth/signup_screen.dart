import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_icons.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_icon.dart';
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
  final _formKey = GlobalKey<FormState>();
  var _obscure = true;
  var _submitting = false;
  String? _error;

  var _regionCode = AppRegion.us.code;
  var _currencyCode = AppRegion.us.defaultCurrencyCode;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onRegionChanged(String code) {
    final region = AppRegion.byCode(code);
    setState(() {
      _regionCode = region.code;
      _currencyCode = region.defaultCurrencyCode;
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final region = AppRegion.byCode(_regionCode);
    final currency = AppCurrency.byCode(_currencyCode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create account'),
        leading: IconButton(
          icon: const AppIcon(AppIcons.clear, size: 22),
          onPressed: () => context.go(AppRoutes.signin),
        ),
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
                Text(
                  'Join SpendWise on this device',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Your name',
                  ),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return 'Enter your name';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Enter your email';
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    helperText: 'At least 6 characters',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: AppIcon(
                        _obscure ? AppIcons.info : AppIcons.clear,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if ((v ?? '').length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Confirm password',
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Region & currency',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Used for all amounts on this account',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _regionCode,
                  decoration: const InputDecoration(
                    labelText: 'Region',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 12, right: 8),
                      child: AppIcon(AppIcons.globe, size: 20),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 44),
                  ),
                  items: [
                    for (final r in AppRegion.all)
                      DropdownMenuItem(
                        value: r.code,
                        child: Text('${r.name} (${r.defaultCurrencyCode})'),
                      ),
                  ],
                  onChanged: _submitting
                      ? null
                      : (code) {
                          if (code != null) _onRegionChanged(code);
                        },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _currencyCode,
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    helperText: 'Default for ${region.name}: ${region.defaultCurrencyCode}',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12, right: 8),
                      child: AppIcon(AppIcons.currency, size: 20),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 44),
                  ),
                  items: [
                    for (final c in AppCurrency.all)
                      DropdownMenuItem(
                        value: c.code,
                        child: Text('${c.name} (${c.symbol})'),
                      ),
                  ],
                  onChanged: _submitting
                      ? null
                      : (code) {
                          if (code != null) {
                            setState(() => _currencyCode = code);
                          }
                        },
                ),
                const SizedBox(height: 8),
                Text(
                  'Amounts will show as ${currency.symbol} ${currency.code}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.tertiaryText(context),
                  ),
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
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(
                    _submitting ? 'Creating account…' : 'Create account',
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed:
                      _submitting ? null : () => context.go(AppRoutes.signin),
                  child: const Text('Already have an account? Sign in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
