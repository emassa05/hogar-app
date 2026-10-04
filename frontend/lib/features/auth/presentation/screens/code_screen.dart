import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_error_code.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../../core/widgets/otp_code_field.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/auth_illustration.dart';
import '../widgets/auth_layout.dart';

class CodeScreen extends ConsumerStatefulWidget {
  const CodeScreen({this.recovery = false, super.key});
  final bool recovery;
  @override
  ConsumerState<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends ConsumerState<CodeScreen> {
  String _code = '';
  Future<void> _submit() async {
    if (await ref.read(authControllerProvider.notifier).confirmCode(_code) &&
        mounted) {
      unawaited(
        context.pushNamed(
          widget.recovery
              ? RouteNames.recoverPassword
              : RouteNames.registerPassword,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final verification = state.verification;
    final exhausted =
        state.error is ApiException &&
        (state.error as ApiException).code ==
            ApiErrorCode.verificationAttemptsExceeded;
    return AuthLayout(
      recovery: widget.recovery,
      step: widget.recovery ? 2 : 1,
      title: AuthStrings.codeTitle,
      accent: AuthStrings.codeAccent,
      description: AuthStrings.codeSentTo(verification?.phone ?? ''),
      illustration: AuthIllustration(
        asset: 'phone-number.png',
        color: AppColors.successSurface,
      ),
      onRetry: exhausted ? null : () => unawaited(_submit()),
      footer: Column(
        children: [
          DeadlineBuilder(
            deadline: verification?.expiresAt,
            builder: (context, remaining) => PrimaryButton(
              label: widget.recovery
                  ? AppStrings.continueAction
                  : AuthStrings.verify,
              loading: state.busy,
              onPressed:
                  CodeValidator.isValidOtp(_code) && remaining > 0 && !exhausted
                  ? () => unawaited(_submit())
                  : null,
            ),
          ),
          TextLinkButton(
            label: AuthStrings.changeNumber,
            onPressed: state.busy
                ? null
                : () => context.goNamed(
                    widget.recovery
                        ? RouteNames.recoverPhone
                        : RouteNames.registerPhone,
                  ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OtpCodeField(
            errorPulse: state.errorPulse,
            enabled: !state.busy,
            onChanged: (value) => setState(() => _code = value),
          ),
          const SizedBox(height: 12),
          DeadlineBuilder(
            deadline: verification?.resendAvailableAt,
            builder: (context, remaining) => remaining > 0
                ? Text(
                    AuthStrings.resendIn(AppStrings.timeRemaining(remaining)),
                    style: AppTypography.bodySmall,
                  )
                : TextLinkButton(
                    label: AuthStrings.resend,
                    loading: state.busy,
                    onPressed: () => unawaited(
                      ref.read(authControllerProvider.notifier).resendCode(),
                    ),
                  ),
          ),
          DeadlineBuilder(
            deadline: verification?.expiresAt,
            builder: (context, remaining) => remaining == 0
                ? const Text(
                    AuthStrings.codeExpired,
                    style: AppTypography.bodySmall,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
