import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/motion/app_haptics.dart';
import '../../../../core/motion/pressable_scale.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/session/session_user.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../../core/widgets/deadline_builder.dart';
import '../../../households/presentation/household_strings.dart';
import '../../../households/presentation/widgets/household_layout.dart';
import '../../domain/profile_entities.dart';
import '../profile_controller.dart';
import '../widgets/capacity_card.dart';

const avatarAccents = {
  AvatarChoice.indigo: AppColors.categoryOne,
  AvatarChoice.green: AppColors.categoryTwo,
  AvatarChoice.yellow: AppColors.categoryThree,
  AvatarChoice.peach: AppColors.categoryFour,
  AvatarChoice.sky: AppColors.categorySix,
  AvatarChoice.pink: Color(0xFFD94A85),
};

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({required this.householdId, super.key});
  final String householdId;
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _nickname = TextEditingController();
  bool _seeded = false;
  int? _capacity;
  AvatarChoice? _avatar;

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  void _seed(MemberProfile profile) {
    if (_seeded) return;
    _seeded = true;
    _nickname.text = profile.nickname ?? '';
    _capacity = profile.proposedCapacityPercent;
    _avatar =
        profile.avatar ?? ref.read(sessionControllerProvider).user?.avatar;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    final saved = await ref
        .read(profileControllerProvider(widget.householdId).notifier)
        .saveProfile(_nickname.text, _capacity, _avatar);
    if (!saved || !mounted) return;
    unawaited(AppHaptics.commit());
    unawaited(
      context.pushNamed(
        RouteNames.householdAvailability,
        pathParameters: {'householdId': widget.householdId},
      ),
    );
  }

  String? _nicknameRule(String? value) {
    final text = value?.trim() ?? '';
    return text.characters.length > 40 ? HouseholdStrings.nicknameLength : null;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(profileControllerProvider(widget.householdId));
    final view = async.valueOrNull;
    if (view != null) _seed(view.profile);
    final busy = view?.busy ?? false;
    return HouseholdLayout(
      title: HouseholdStrings.profile,
      step: 3,
      busy: busy,
      footer: DeadlineBuilder(
        deadline: view?.blockedUntil,
        builder: (context, seconds) => PrimaryButton(
          label: HouseholdStrings.saveAndContinue,
          compact: true,
          loading: busy,
          onPressed: view == null || seconds > 0
              ? null
              : () => unawaited(_submit()),
        ),
      ),
      child: view == null
          ? LoadPlaceholder(
              error: async.hasError && !async.isLoading
                  ? asAppException(async.error)
                  : null,
              onRetry: () =>
                  ref.invalidate(profileControllerProvider(widget.householdId)),
            )
          : Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Identity(
                    name: view.profile.name,
                    avatar: _avatar,
                    enabled: !busy,
                    onAvatar: (value) {
                      unawaited(AppHaptics.selection());
                      setState(() => _avatar = value);
                    },
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: HouseholdStrings.nickname,
                    controller: _nickname,
                    compact: true,
                    hintText: view.profile.name,
                    helperText: HouseholdStrings.nicknameShort,
                    textCapitalization: TextCapitalization.words,
                    enabled: !busy,
                    validator: _nicknameRule,
                    errorText: ErrorMessages.field(view.error, 'nickname'),
                    onChanged: (_) => ref
                        .read(
                          profileControllerProvider(
                            widget.householdId,
                          ).notifier,
                        )
                        .clearError(),
                  ),
                  const SizedBox(height: 18),
                  CapacityCard(
                    value: _capacity,
                    enabled: !busy,
                    errorText: ErrorMessages.field(
                      view.error,
                      'proposed_capacity_percent',
                    ),
                    onChanged: (value) {
                      if (value != _capacity) {
                        unawaited(AppHaptics.selection());
                      }
                      setState(() => _capacity = value);
                    },
                  ),
                  if (view.error != null &&
                      ErrorMessages.field(view.error, 'nickname') == null) ...[
                    const SizedBox(height: 18),
                    SaveFeedback(
                      error: view.error,
                      savedPart: view.savedPart,
                      onRetry: busy ? null : () => unawaited(_submit()),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({
    required this.name,
    required this.avatar,
    required this.onAvatar,
    required this.enabled,
  });
  final String name;
  final AvatarChoice? avatar;
  final ValueChanged<AvatarChoice> onAvatar;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AvatarCircle(
        avatar: avatar,
        name: name,
        size: 64,
        borderWidth: 1.5,
        borderColor: avatarAccents[avatar] ?? AppColors.categoryOne,
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppTypography.titleLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 0,
              runSpacing: 0,
              children: [
                for (final choice in AvatarChoice.values)
                  _AvatarDot(
                    choice: choice,
                    selected: choice == avatar,
                    onTap: enabled ? () => onAvatar(choice) : null,
                  ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              HouseholdStrings.accountAvatar,
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    ],
  );
}

class _AvatarDot extends StatelessWidget {
  const _AvatarDot({required this.choice, required this.selected, this.onTap});
  final AvatarChoice choice;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    inMutuallyExclusiveGroup: true,
    selected: selected,
    enabled: onTap != null,
    label: HouseholdStrings.avatarOption(AvatarCircle.names[choice]!),
    excludeSemantics: true,
    child: PressableScale(
      enabled: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: 36,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: avatarAccents[choice],
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: AppColors.borderSelected, width: 2)
                    : null,
                boxShadow: selected
                    ? const [
                        BoxShadow(spreadRadius: 2, color: AppColors.surface),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
