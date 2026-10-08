import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/session/session_user.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/character_picker.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../households/presentation/household_strings.dart';
import '../../../households/presentation/widgets/household_layout.dart';
import '../profile_controller.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({required this.householdId, super.key});
  final String householdId;
  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _nickname = TextEditingController();
  String? _seededUser;
  AvatarChoice? _avatar;

  @override
  void dispose() {
    _name.dispose();
    _nickname.dispose();
    super.dispose();
  }

  void _back() => context.goNamed(
    RouteNames.memberProfile,
    pathParameters: {'householdId': widget.householdId, 'userId': 'me'},
  );

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    final saved = await ref
        .read(profileControllerProvider(widget.householdId).notifier)
        .saveIdentity(_name.text, _nickname.text, _avatar);
    if (saved && mounted) _back();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionControllerProvider).user;
    final async = ref.watch(profileControllerProvider(widget.householdId));
    final view = async.isLoading || async.hasError ? null : async.asData?.value;
    final eligible =
        user?.activeHouseholdId == widget.householdId &&
        (view?.profile.isMe ?? false);
    if (eligible && user != null && _seededUser != user.id) {
      _seededUser = user.id;
      _name.text = user.name;
      _nickname.text = view!.profile.nickname ?? '';
      _avatar = user.avatar;
    }
    final busy = view?.busy ?? false;
    return HouseholdLayout(
      title: HouseholdStrings.editProfile,
      onBack: _back,
      busy: busy,
      footer: DeadlineBuilder(
        deadline: view?.blockedUntil,
        builder: (context, seconds) => PrimaryButton(
          label: HouseholdStrings.saveChanges,
          compact: true,
          loading: busy,
          onPressed: eligible && seconds == 0 ? () => unawaited(_save()) : null,
        ),
      ),
      child: user?.activeHouseholdId != widget.householdId
          ? const Text(HouseholdStrings.inactiveHousehold)
          : view == null
          ? LoadPlaceholder(
              error: async.hasError ? asAppException(async.error) : null,
              onRetry: () =>
                  ref.invalidate(profileControllerProvider(widget.householdId)),
            )
          : !eligible
          ? const Text(HouseholdStrings.foreignProfileReadOnly)
          : Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CharacterPicker(
                    label: HouseholdStrings.character,
                    showSelectionCheck: true,
                    selected: _avatar,
                    enabled: !busy,
                    onSelected: (value) => setState(() => _avatar = value),
                  ),
                  const SizedBox(height: 16),
                  const Text(HouseholdStrings.accountAvatar),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: HouseholdStrings.accountName,
                    controller: _name,
                    enabled: !busy,
                    compact: true,
                    helperText: HouseholdStrings.accountNameHelp,
                    validator: NameValidator.validate,
                    errorText: ErrorMessages.field(view.error, 'name'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: HouseholdStrings.householdNickname,
                    controller: _nickname,
                    enabled: !busy,
                    compact: true,
                    helperText: HouseholdStrings.nicknameHelp,
                    validator: (value) => (value?.trim().runes.length ?? 0) > 40
                        ? HouseholdStrings.nicknameLength
                        : null,
                    errorText: ErrorMessages.field(view.error, 'nickname'),
                  ),
                  const SizedBox(height: 16),
                  SaveFeedback(
                    error: view.error,
                    savedPart: view.savedPart,
                    onRetry: busy ? null : () => unawaited(_save()),
                  ),
                ],
              ),
            ),
    );
  }
}
