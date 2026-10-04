import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/motion/app_haptics.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_halo.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/password_rules_checklist.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/access_illustration.dart';
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
  final _confirmationFocus = FocusNode();

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
    _confirmationFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    final controller = ref.read(authControllerProvider.notifier);
    if (widget.recovery) {
      if (await controller.resetPassword(_password.text)) {
        unawaited(AppHaptics.success());
      }
    } else if (controller.savePassword(_password.text)) {
      unawaited(AppHaptics.commit());
      if (mounted) unawaited(context.pushNamed(RouteNames.registerName));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final rules = PasswordRules(_password.text);
    final matches =
        _confirmation.text.isNotEmpty &&
        _password.text.trim() == _confirmation.text.trim();
    final fieldError = ErrorMessages.field(
      state.error,
      widget.recovery ? 'new_password' : 'password',
    );
    return AuthLayout(
      recovery: widget.recovery,
      step: widget.recovery ? 3 : 2,
      scene: AccessScene.password,
      haloAccent: AppHalos.butter,
      contentGap: 20,
      title: widget.recovery
          ? AuthStrings.newPasswordTitle
          : AuthStrings.passwordTitle,
      accent: AuthStrings.passwordAccent,
      description: TextSpan(
        text: widget.recovery
            ? AuthStrings.newPasswordBody
            : AuthStrings.passwordBody,
      ),
      bannerError: fieldError == null ? state.error : null,
      onRetry: () => unawaited(_submit()),
      footer: PrimaryButton(
        label: widget.recovery
            ? AuthStrings.saveAndEnter
            : AppStrings.continueAction,
        loading: state.busy,
        trailingIcon: AppIcons.arrowRight,
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
              errorText: fieldError,
              textInputAction: widget.recovery
                  ? TextInputAction.next
                  : TextInputAction.done,
              onSubmitted: (_) => widget.recovery
                  ? _confirmationFocus.requestFocus()
                  : unawaited(_submit()),
              onChanged: (_) {
                ref.read(authControllerProvider.notifier).clearError();
                setState(() {});
              },
            ),
            SizedBox(height: widget.recovery ? 16 : 20),
            PasswordRulesChecklist(
              password: _password.text,
              showRules: !widget.recovery || !rules.isValid,
            ),
            if (widget.recovery) ...[
              const SizedBox(height: 16),
              PasswordField(
                label: AuthStrings.repeatPassword,
                controller: _confirmation,
                focusNode: _confirmationFocus,
                enabled: !state.busy,
                successText: matches ? AuthStrings.passwordsMatch : null,
                validator: (value) =>
                    value?.trim() == _password.text.trim() &&
                        (value?.isNotEmpty ?? false)
                    ? null
                    : AuthStrings.passwordsMismatch,
                onSubmitted: (_) => unawaited(_submit()),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
