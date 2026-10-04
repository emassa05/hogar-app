import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_error_code.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_halo.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../../core/widgets/field_message.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../domain/auth_entities.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/access_illustration.dart';
import '../widgets/auth_layout.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({this.recovery = false, super.key});
  final bool recovery;
  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();

  VerificationPurpose get _purpose => widget.recovery
      ? VerificationPurpose.passwordReset
      : VerificationPurpose.registration;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(authControllerProvider);
    final saved = draft.purpose == _purpose ? draft.verification?.phone : null;
    if (saved != null) {
      _phone.text = ChileanPhoneFormatter.format(saved.replaceFirst('+56', ''));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(authControllerProvider).purpose != _purpose) {
        ref.read(authControllerProvider.notifier).reset(purpose: _purpose);
      }
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    if (await ref
            .read(authControllerProvider.notifier)
            .requestCode(_phone.text) &&
        mounted) {
      unawaited(
        context.pushNamed(
          widget.recovery ? RouteNames.recoverCode : RouteNames.registerCode,
        ),
      );
    }
  }

  String? _phoneError(AppException? error) {
    final field = ErrorMessages.field(error, 'phone');
    if (field != null) return field;
    if (error is ApiException &&
        error.code == ApiErrorCode.phoneAlreadyRegistered) {
      return ErrorMessages.forException(error);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final error = state.error;
    final fieldError = _phoneError(error);
    final blocked = error is ApiException && error.retryAfterSeconds != null;
    return AuthLayout(
      recovery: widget.recovery,
      step: 1,
      scene: widget.recovery ? AccessScene.recover : AccessScene.phone,
      haloAccent: widget.recovery ? const Color(0xFFC9C3FA) : AppHalos.mint,
      title: widget.recovery
          ? AuthStrings.recoverTitle
          : AuthStrings.phoneTitle,
      accent: widget.recovery
          ? AuthStrings.recoverAccent
          : AuthStrings.phoneAccent,
      description: TextSpan(
        text: widget.recovery ? AuthStrings.recoverBody : AuthStrings.phoneBody,
      ),
      bannerError: fieldError == null && !blocked ? error : null,
      onRetry: () => unawaited(_submit()),
      footer: DeadlineBuilder(
        deadline: state.blockedUntil,
        builder: (context, seconds) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryButton(
              label: AuthStrings.sendCode,
              loading: state.busy,
              trailingIcon: AppIcons.arrowRight,
              onPressed: seconds == 0 ? () => unawaited(_submit()) : null,
            ),
            InlineLinkText(
              prefix: widget.recovery
                  ? AuthStrings.remembered
                  : AuthStrings.haveAccount,
              action: AuthStrings.signIn,
              onPressed: state.busy
                  ? null
                  : () {
                      ref.read(authControllerProvider.notifier).reset();
                      context.goNamed(RouteNames.login);
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
              errorText: fieldError,
              helperText: widget.recovery ? null : AuthStrings.phonePrivacy,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => unawaited(_submit()),
              onChanged: (_) =>
                  ref.read(authControllerProvider.notifier).clearError(),
            ),
            DeadlineBuilder(
              deadline: state.blockedUntil,
              builder: (context, seconds) => seconds == 0
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: FieldMessage(
                        text: AuthStrings.tryAgainIn(
                          AppStrings.timeRemaining(seconds),
                        ),
                        tone: FieldMessageTone.error,
                        icon: AppIcons.clock,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
