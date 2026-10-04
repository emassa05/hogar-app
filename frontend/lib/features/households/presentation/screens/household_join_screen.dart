import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_error_code.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/motion/app_haptics.dart';
import '../../../../core/motion/motion_reveal.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../domain/household_entities.dart';
import '../household_controller.dart';
import '../household_strings.dart';
import '../widgets/household_layout.dart';

const _codeErrors = {
  ApiErrorCode.invitationNotFound,
  ApiErrorCode.invitationExpired,
};

class InvitationCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.toUpperCase().replaceAll(RegExp('[^0-9A-Z]'), '');
    final limited = raw.length > 8 ? raw.substring(0, 8) : raw;
    final text = limited.length > 4
        ? '${limited.substring(0, 4)}-${limited.substring(4)}'
        : limited;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class HouseholdJoinScreen extends ConsumerStatefulWidget {
  const HouseholdJoinScreen({super.key});
  @override
  ConsumerState<HouseholdJoinScreen> createState() =>
      _HouseholdJoinScreenState();
}

class _HouseholdJoinScreenState extends ConsumerState<HouseholdJoinScreen> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  HouseholdController get _controller =>
      ref.read(householdControllerProvider.notifier);

  Future<void> _preview() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    await _controller.preview(_code.text);
  }

  Future<void> _accept() async {
    if (!await _controller.accept() || !mounted) return;
    unawaited(AppHaptics.success());
    context.goNamed(RouteNames.home);
  }

  Future<void> _openExisting(String id) async {
    if (!await _controller.openExisting(id) || !mounted) return;
    context.goNamed(RouteNames.home);
  }

  void _changed(String value) {
    final state = ref.read(householdControllerProvider);
    if (state.preview != null || state.error != null) {
      _controller.clearPreview();
    }
    if (CodeValidator.isValidInvitation(value)) unawaited(_preview());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(householdControllerProvider);
    final error = state.error;
    final codeError = error is ApiException && _codeErrors.contains(error.code)
        ? ErrorMessages.forException(error)
        : ErrorMessages.field(error, 'code');
    final alreadyMember =
        error is ApiException && error.code == ApiErrorCode.alreadyMember
        ? error.details['household_id']
        : null;
    final preview = state.preview;
    return HouseholdLayout(
      title: HouseholdStrings.joinTitle,
      busy: state.busy,
      footer: DeadlineBuilder(
        deadline: state.blockedUntil,
        builder: (context, seconds) => PrimaryButton(
          label: preview == null
              ? HouseholdStrings.preview
              : HouseholdStrings.joinHome,
          compact: true,
          loading: state.busy,
          onPressed: seconds > 0
              ? null
              : preview == null
              ? () => unawaited(_preview())
              : () => unawaited(_accept()),
        ),
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: HouseholdStrings.invitationCode,
              controller: _code,
              compact: true,
              hintText: HouseholdStrings.codeHint,
              helperText: HouseholdStrings.codeHelp,
              keyboardType: TextInputType.visiblePassword,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              inputFormatters: [InvitationCodeFormatter()],
              enabled: !state.busy || preview != null,
              validator: (value) => CodeValidator.isValidInvitation(value ?? '')
                  ? null
                  : HouseholdStrings.invalidInvitation,
              autovalidateMode: AutovalidateMode.disabled,
              errorText: codeError,
              onSubmitted: (_) => unawaited(_preview()),
              onChanged: _changed,
            ),
            if (preview != null) ...[
              const SizedBox(height: 20),
              MotionReveal(child: _PreviewCard(preview: preview)),
            ],
            if (alreadyMember is String) ...[
              const SizedBox(height: 20),
              InfoBanner(
                message: ErrorMessages.forException(error!),
                action: TextLinkButton(
                  label: HouseholdStrings.openExisting,
                  onPressed: state.busy
                      ? null
                      : () => unawaited(_openExisting(alreadyMember)),
                ),
              ),
            ] else if (error != null && codeError == null) ...[
              const SizedBox(height: 20),
              SaveFeedback(
                error: error,
                savedPart: state.savedPart,
                onRetry: state.busy
                    ? null
                    : () => unawaited(preview == null ? _preview() : _accept()),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              HouseholdStrings.joinNote,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview});
  final InvitationPreview preview;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    container: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(preview.householdName, style: AppTypography.titleSmall),
          const SizedBox(height: 2),
          Text(
            HouseholdStrings.memberCount(preview.memberCount),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    ),
  );
}
