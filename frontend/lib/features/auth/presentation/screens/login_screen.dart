import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_error_code.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_halo.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../domain/auth_entities.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/access_illustration.dart';
import '../widgets/auth_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(_phone.text, _password.text);
  }

  void _clear() => ref.read(authControllerProvider.notifier).clearError();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final error = state.error;
    final credentials =
        error is ApiException && error.code == ApiErrorCode.invalidCredentials;
    final phoneError = ErrorMessages.field(error, 'phone');
    final passwordError =
        ErrorMessages.field(error, 'password') ??
        (credentials ? ErrorMessages.forException(error) : null);
    final handled =
        phoneError != null ||
        passwordError != null ||
        (error is ApiException && error.code == ApiErrorCode.accountLocked);
    return AuthLayout(
      scene: AccessScene.login,
      haloAccent: AppHalos.rose,
      title: AuthStrings.loginTitle,
      accent: AuthStrings.loginAccent,
      description: const TextSpan(text: AuthStrings.loginBody),
      bannerError: handled ? null : error,
      onRetry: () => unawaited(_submit()),
      footer: DeadlineBuilder(
        deadline: state.blockedUntil,
        builder: (context, seconds) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(
              label: AuthStrings.enter,
              loading: state.busy,
              trailingIcon: AppIcons.arrowRight,
              onPressed: seconds == 0 ? () => unawaited(_submit()) : null,
            ),
            InlineLinkText(
              prefix: AuthStrings.noAccount,
              action: AuthStrings.createAccount,
              onPressed: state.busy
                  ? null
                  : () {
                      ref.read(authControllerProvider.notifier).reset();
                      context.goNamed(RouteNames.registerPhone);
                    },
            ),
          ],
        ),
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PhoneField(
              controller: _phone,
              enabled: !state.busy,
              errorText: phoneError,
              onSubmitted: (_) => _passwordFocus.requestFocus(),
              onChanged: (_) => _clear(),
            ),
            const SizedBox(height: 16),
            DeadlineBuilder(
              deadline: state.blockedUntil,
              builder: (context, seconds) => PasswordField(
                controller: _password,
                focusNode: _passwordFocus,
                enabled: !state.busy,
                newPassword: false,
                errorText: seconds > 0
                    ? AuthStrings.lockedFor(AppStrings.timeRemaining(seconds))
                    : passwordError,
                onSubmitted: (_) => unawaited(_submit()),
                onChanged: (_) => _clear(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextLinkButton(
                label: AuthStrings.forgotPassword,
                underline: true,
                style: AppTypography.link,
                onPressed: state.busy
                    ? null
                    : () {
                        ref
                            .read(authControllerProvider.notifier)
                            .reset(purpose: VerificationPurpose.passwordReset);
                        unawaited(context.pushNamed(RouteNames.recoverPhone));
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
