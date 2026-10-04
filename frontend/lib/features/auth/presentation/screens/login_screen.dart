import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../../core/widgets/password_field.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../domain/auth_entities.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/auth_illustration.dart';
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
  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(_phone.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return AuthLayout(
      title: AuthStrings.loginTitle,
      accent: AuthStrings.loginAccent,
      description: AuthStrings.loginBody,
      illustration: const AuthIllustration(asset: 'login-wave.png'),
      onRetry: () => unawaited(_submit()),
      footer: Column(
        children: [
          DeadlineBuilder(
            deadline: state.blockedUntil,
            builder: (context, seconds) => PrimaryButton(
              label: seconds > 0
                  ? AuthStrings.lockedFor(AppStrings.timeRemaining(seconds))
                  : AuthStrings.enter,
              loading: state.busy,
              icon: Icons.arrow_forward,
              onPressed: seconds == 0 ? () => unawaited(_submit()) : null,
            ),
          ),
          TextLinkButton(
            label: AuthStrings.newAccountLink,
            onPressed: state.busy
                ? null
                : () {
                    ref.read(authControllerProvider.notifier).reset();
                    context.goNamed(RouteNames.registerPhone);
                  },
          ),
        ],
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PhoneField(
              controller: _phone,
              enabled: !state.busy,
              errorText: ErrorMessages.field(state.error, 'phone'),
              onChanged: (_) =>
                  ref.read(authControllerProvider.notifier).clearError(),
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _password,
              enabled: !state.busy,
              newPassword: false,
              errorText: ErrorMessages.field(state.error, 'password'),
              onChanged: (_) =>
                  ref.read(authControllerProvider.notifier).clearError(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextLinkButton(
                label: AuthStrings.forgotPassword,
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
