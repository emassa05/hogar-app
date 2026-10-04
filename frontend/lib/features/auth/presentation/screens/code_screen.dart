import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_error_code.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/motion/app_haptics.dart';
import '../../../../core/motion/motion_tokens.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../../core/widgets/field_message.dart';
import '../../../../core/widgets/otp_code_field.dart';
import '../../../../core/widgets/phone_field.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/access_illustration.dart';
import '../widgets/auth_layout.dart';

const _codeErrors = {
  ApiErrorCode.verificationCodeInvalid,
  ApiErrorCode.verificationAttemptsExceeded,
  ApiErrorCode.verificationExpired,
  ApiErrorCode.verificationNotFound,
  ApiErrorCode.verificationResendTooSoon,
};

class CodeScreen extends ConsumerStatefulWidget {
  const CodeScreen({this.recovery = false, super.key});
  final bool recovery;
  @override
  ConsumerState<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends ConsumerState<CodeScreen> {
  String _code = '';
  bool _verified = false;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final confirmed = await ref
        .read(authControllerProvider.notifier)
        .confirmCode(_code);
    if (!confirmed || !mounted) return;
    setState(() => _verified = true);
    unawaited(AppHaptics.success());
    final reduced = MediaQuery.disableAnimationsOf(context);
    await Future<void>.delayed(
      reduced ? Duration.zero : MotionTokens.entrance * 2,
    );
    if (!mounted) return;
    unawaited(
      context.pushNamed(
        widget.recovery
            ? RouteNames.recoverPassword
            : RouteNames.registerPassword,
      ),
    );
  }

  Future<void> _resend() async {
    setState(() => _verified = false);
    await ref.read(authControllerProvider.notifier).resendCode();
  }

  Widget _resendRow(DateTime? availableAt, bool busy) => DeadlineBuilder(
    deadline: availableAt,
    builder: (context, remaining) => remaining > 0
        ? Semantics(
            liveRegion: false,
            label:
                '${AuthStrings.resendWaiting}${AppStrings.timeRemaining(remaining)}',
            excludeSemantics: true,
            child: Row(
              children: [
                const AppIcon(AppIcons.clock, color: AppColors.iconTertiary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: AuthStrings.resendWaiting),
                        TextSpan(
                          text: AppStrings.timeRemaining(remaining),
                          style: AppTypography.dataBody,
                        ),
                      ],
                    ),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Align(
            alignment: Alignment.centerLeft,
            child: InlineLinkText(
              prefix: AuthStrings.resendPrompt,
              action: AuthStrings.resend,
              centered: false,
              onPressed: busy ? null : () => unawaited(_resend()),
            ),
          ),
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final verification = state.verification;
    final error = state.error;
    final codeError = error is ApiException && _codeErrors.contains(error.code)
        ? error
        : null;
    final exhausted =
        codeError?.code == ApiErrorCode.verificationAttemptsExceeded ||
        codeError?.code == ApiErrorCode.verificationExpired ||
        codeError?.code == ApiErrorCode.verificationNotFound;
    final invalid = codeError?.code == ApiErrorCode.verificationCodeInvalid;
    return AuthLayout(
      recovery: widget.recovery,
      step: widget.recovery ? 2 : 1,
      scene: AccessScene.verify,
      title: AuthStrings.codeTitle,
      accent: AuthStrings.codeAccent,
      description: TextSpan(
        children: [
          const TextSpan(text: AuthStrings.codeSentStart),
          TextSpan(
            text: displayPhone(verification?.phone ?? '').replaceAll(' ', ' '),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      bannerError: codeError == null ? error : null,
      onRetry: () => unawaited(_submit()),
      footer: DeadlineBuilder(
        deadline: verification?.expiresAt,
        builder: (context, remaining) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(
              label: widget.recovery
                  ? AppStrings.continueAction
                  : AuthStrings.verify,
              loading: state.busy,
              trailingIcon: widget.recovery ? AppIcons.arrowRight : null,
              onPressed:
                  CodeValidator.isValidOtp(_code) &&
                      remaining > 0 &&
                      !exhausted &&
                      !_verified
                  ? () => unawaited(_submit())
                  : null,
            ),
            if (!widget.recovery)
              InlineLinkText(
                prefix: AuthStrings.wrongNumber,
                action: AuthStrings.changeNumber,
                onPressed: state.busy
                    ? null
                    : () => context.goNamed(RouteNames.registerPhone),
              ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OtpCodeField(
            errorPulse: state.errorPulse,
            enabled: !state.busy && !_verified,
            status: _verified
                ? OtpStatus.success
                : invalid
                ? OtpStatus.error
                : OtpStatus.idle,
            onChanged: (value) {
              setState(() => _code = value);
              if (state.error != null) {
                ref.read(authControllerProvider.notifier).clearError();
              }
            },
          ),
          const SizedBox(height: 14),
          if (_verified)
            const FieldMessage.success(AuthStrings.codeCorrect)
          else ...[
            if (codeError != null &&
                codeError.code != ApiErrorCode.verificationResendTooSoon) ...[
              FieldMessage.error(ErrorMessages.forException(codeError)),
              const SizedBox(height: 4),
            ],
            DeadlineBuilder(
              deadline: verification?.expiresAt,
              builder: (context, remaining) =>
                  remaining == 0 && codeError == null
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: FieldMessage.error(AuthStrings.codeExpired),
                    )
                  : const SizedBox.shrink(),
            ),
            _resendRow(verification?.resendAvailableAt, state.busy),
          ],
        ],
      ),
    );
  }
}
