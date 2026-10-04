import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/motion/app_haptics.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../../core/widgets/info_banner.dart';
import '../household_controller.dart';
import '../household_strings.dart';
import '../widgets/household_layout.dart';

class HouseholdCreateScreen extends ConsumerStatefulWidget {
  const HouseholdCreateScreen({super.key});
  @override
  ConsumerState<HouseholdCreateScreen> createState() =>
      _HouseholdCreateScreenState();
}

class _HouseholdCreateScreenState extends ConsumerState<HouseholdCreateScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    final controller = ref.read(householdControllerProvider.notifier);
    if (!await controller.create(_name.text) || !mounted) return;
    unawaited(AppHaptics.commit());
    final id = ref.read(householdControllerProvider).household!.id;
    context.pushReplacementNamed(
      RouteNames.householdInvite,
      pathParameters: {'householdId': id},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(householdControllerProvider);
    final fieldError = ErrorMessages.field(state.error, 'name');
    return HouseholdLayout(
      title: HouseholdStrings.newHousehold,
      step: 1,
      busy: state.busy,
      footer: DeadlineBuilder(
        deadline: state.blockedUntil,
        builder: (context, seconds) => PrimaryButton(
          label: HouseholdStrings.continueLabel,
          compact: true,
          loading: state.busy,
          onPressed: seconds == 0 ? () => unawaited(_submit()) : null,
        ),
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: HouseholdStrings.householdName,
              controller: _name,
              compact: true,
              hintText: HouseholdStrings.householdHint,
              helperText: HouseholdStrings.nameHelp,
              maxLength: 40,
              showCounter: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              enabled: !state.busy,
              validator: NameValidator.validate,
              errorText: fieldError,
              onSubmitted: (_) => unawaited(_submit()),
              onChanged: (_) =>
                  ref.read(householdControllerProvider.notifier).clearError(),
            ),
            const SizedBox(height: 20),
            const InfoBanner(
              icon: AppIcons.template,
              title: HouseholdStrings.templatesHint,
              message: HouseholdStrings.templatesHintBody,
            ),
            if (state.error != null && fieldError == null) ...[
              const SizedBox(height: 20),
              SaveFeedback(
                error: state.error,
                savedPart: state.savedPart,
                onRetry: state.busy ? null : () => unawaited(_submit()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
