import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/motion/app_haptics.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/password_rules_checklist.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/auth_illustration.dart';
import '../widgets/auth_layout.dart';

class PasswordScreen extends ConsumerStatefulWidget {
  const PasswordScreen({this.recovery = false, super.key});
  final bool recovery;
  @override
  ConsumerState<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (!widget.recovery) {
      _password.text = ref.read(authControllerProvider).password;
    }
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final controller = ref.read(authControllerProvider.notifier);
    if (widget.recovery) {
      await controller.resetPassword(_password.text);
    } else if (controller.savePassword(_password.text)) {
      unawaited(AppHaptics.commit());
      if (mounted) unawaited(context.pushNamed(RouteNames.registerName));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final matches =
        _confirmation.text.isNotEmpty &&
        _password.text.trim() == _confirmation.text.trim();
    return AuthLayout(
      recovery: widget.recovery,
      step: widget.recovery ? 3 : 2,
      title: widget.recovery
          ? AuthStrings.newPasswordTitle
          : AuthStrings.passwordTitle,
      accent: AuthStrings.passwordAccent,
      description: widget.recovery
          ? AuthStrings.newPasswordBody
          : AuthStrings.passwordBody,
      illustration: AuthIllustration(
        asset: 'password-lock.png',
        height: widget.recovery ? 176 : 220,
        color: AppColors.warning,
      ),
      onRetry: () => unawaited(_submit()),
      footer: PrimaryButton(
        label: widget.recovery
            ? AuthStrings.saveAndEnter
            : AppStrings.continueAction,
        loading: state.busy,
        icon: Icons.arrow_forward,
        onPressed: () => unawaited(_submit()),
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PasswordField(
              label: widget.recovery
                  ? AuthStrings.newPassword
                  : AppStrings.password,
              controller: _password,
              enabled: !state.busy,
              errorText: ErrorMessages.field(
                state.error,
                widget.recovery ? 'new_password' : 'password',
              ),
              onChanged: (_) {
                ref.read(authControllerProvider.notifier).clearError();
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            PasswordRulesChecklist(password: _password.text),
            if (widget.recovery) ...[
              const SizedBox(height: 16),
              PasswordField(
                label: AuthStrings.repeatPassword,
                controller: _confirmation,
                enabled: !state.busy,
                validator: (value) =>
                    value?.trim() == _password.text.trim() &&
                        (value?.isNotEmpty ?? false)
                    ? null
                    : AuthStrings.passwordsMismatch,
                onChanged: (_) => setState(() {}),
              ),
              if (matches) ...[
                const SizedBox(height: 8),
                Text(
                  AuthStrings.passwordsMatch,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
