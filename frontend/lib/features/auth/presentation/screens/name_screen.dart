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
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_halo.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../../core/widgets/section_label.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';
import '../widgets/access_illustration.dart';
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
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    if (ref.read(authControllerProvider.notifier).saveName(_name.text)) {
      unawaited(AppHaptics.commit());
      unawaited(context.pushNamed(RouteNames.registerCharacter));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final name = _name.text.trim();
    return AuthLayout(
      step: 3,
      scene: AccessScene.name,
      haloAccent: AppHalos.peach,
      title: AuthStrings.nameTitle,
      accent: AuthStrings.nameAccent,
      description: const TextSpan(text: AuthStrings.nameBody),
      footer: PrimaryButton(
        label: AppStrings.continueAction,
        trailingIcon: AppIcons.arrowRight,
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
              showCounter: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.nickname],
              validator: NameValidator.validate,
              errorText: ErrorMessages.field(state.error, 'name'),
              onSubmitted: (_) => _submit(),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: AppTag(label: AuthStrings.preview),
            ),
            const SizedBox(height: 8),
            MergeSemantics(
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                color: AppColors.surface.withValues(alpha: 0.7),
                borderColor: AppColors.borderSubtle,
                child: Row(
                  children: [
                    AvatarCircle(
                      name: name.isEmpty ? '' : name.characters.first,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? AuthStrings.name : name,
                            style: AppTypography.cardTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AuthStrings.previewTask,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
