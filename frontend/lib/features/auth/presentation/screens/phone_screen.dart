import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../../core/widgets/phone_field.dart';
import '../../domain/auth_entities.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/auth_illustration.dart';
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
  @override
  void initState() {
    super.initState();
    final draft = ref.read(authControllerProvider);
    _phone.text = draft.verification?.phone.replaceFirst('+56', '') ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final purpose = widget.recovery
          ? VerificationPurpose.passwordReset
          : VerificationPurpose.registration;
      if (ref.read(authControllerProvider).purpose != purpose) {
        ref.read(authControllerProvider.notifier).reset(purpose: purpose);
      }
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return AuthLayout(
      recovery: widget.recovery,
      step: 1,
      title: widget.recovery
          ? AuthStrings.recoverTitle
          : AuthStrings.phoneTitle,
      accent: widget.recovery
          ? AuthStrings.recoverAccent
          : AuthStrings.phoneAccent,
      description: widget.recovery
          ? AuthStrings.recoverBody
          : AuthStrings.phoneBody,
      illustration: AuthIllustration(
        asset: widget.recovery ? 'recover-magnifier.png' : 'phone-number.png',
        color: widget.recovery ? AppColors.brand : AppColors.successSurface,
      ),
      onRetry: () => unawaited(_submit()),
      footer: Column(
        children: [
          DeadlineBuilder(
            deadline: state.blockedUntil,
            builder: (context, seconds) => PrimaryButton(
              label: seconds > 0
                  ? AuthStrings.lockedFor(
                      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                    )
                  : AuthStrings.sendCode,
              loading: state.busy,
              onPressed: seconds == 0 ? () => unawaited(_submit()) : null,
              icon: Icons.arrow_forward,
            ),
          ),
          TextLinkButton(
            label: widget.recovery
                ? AuthStrings.rememberedPassword
                : AuthStrings.loginLink,
            onPressed: state.busy
                ? null
                : () {
                    ref.read(authControllerProvider.notifier).reset();
                    context.goNamed(RouteNames.login);
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
            if (!widget.recovery) ...[
              const SizedBox(height: 8),
              const Text(
                AuthStrings.phonePrivacy,
                style: AppTypography.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
