import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/motion/app_haptics.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/auth_illustration.dart';
import '../widgets/auth_layout.dart';

class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key});
  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  @override
  void initState() {
    super.initState();
    _name.text = ref.read(authControllerProvider).name;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    if (ref.read(authControllerProvider.notifier).saveName(_name.text)) {
      unawaited(AppHaptics.commit());
      unawaited(context.pushNamed(RouteNames.registerCharacter));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    return AuthLayout(
      step: 3,
      title: AuthStrings.nameTitle,
      accent: AuthStrings.nameAccent,
      description: AuthStrings.nameBody,
      illustration: const AuthIllustration(
        asset: 'name-tag.png',
        color: Color(0xFFEB985E),
      ),
      footer: PrimaryButton(
        label: AppStrings.continueAction,
        icon: Icons.arrow_forward,
        onPressed: _submit,
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: AuthStrings.name,
              controller: _name,
              maxLength: 40,
              autofillHints: const [AutofillHints.nickname],
              validator: NameValidator.validate,
              errorText: ErrorMessages.field(state.error, 'name'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            const Text(AuthStrings.preview, style: AppTypography.dataSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(AppRadius.large),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  AvatarCircle(name: _name.text),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name.text.trim().isEmpty
                              ? AuthStrings.name
                              : _name.text.trim(),
                          style: AppTypography.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          AuthStrings.previewTask,
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
