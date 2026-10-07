import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/motion/app_haptics.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/info_banner.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/step_header.dart';
import '../../domain/household_entities.dart';
import '../household_controller.dart';
import '../household_strings.dart';
import '../widgets/household_layout.dart';
import '../widgets/invitation_code_card.dart';
import '../widgets/member_tile.dart';

class HouseholdInviteScreen extends ConsumerStatefulWidget {
  const HouseholdInviteScreen({
    required this.householdId,
    this.settingsMode = false,
    super.key,
  });
  final String householdId;
  final bool settingsMode;
  @override
  ConsumerState<HouseholdInviteScreen> createState() =>
      _HouseholdInviteScreenState();
}

class _HouseholdInviteScreenState extends ConsumerState<HouseholdInviteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_load()));
  }

  Future<void> _load() async {
    if (widget.settingsMode &&
        ref.read(sessionControllerProvider).user?.activeHouseholdId !=
            widget.householdId) {
      return;
    }
    await ref
        .read(householdControllerProvider.notifier)
        .load(widget.householdId);
  }

  Future<void> _copy(String code) async {
    await Clipboard.setData(
      ClipboardData(text: CodeValidator.displayInvitation(code)),
    );
    unawaited(AppHaptics.selection());
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(HouseholdStrings.copied)));
  }

  Future<void> _share(HouseholdDetail household, Invitation invitation) =>
      Share.share(
        HouseholdStrings.shareMessage(
          household.name,
          CodeValidator.displayInvitation(invitation.code),
          invitation.shareUrl,
        ),
        subject: household.name,
      );

  Future<void> _act(Member member, MemberAction action) async {
    final controller = ref.read(householdControllerProvider.notifier);
    switch (action) {
      case MemberAction.makeAdmin:
        await controller.changeRole(
          widget.householdId,
          member.userId,
          MemberRole.admin,
        );
      case MemberAction.makeMember:
        await controller.changeRole(
          widget.householdId,
          member.userId,
          MemberRole.member,
        );
      case MemberAction.remove:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(HouseholdStrings.removeQuestion),
            content: Text(member.displayName),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(HouseholdStrings.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(HouseholdStrings.confirm),
              ),
            ],
          ),
        );
        if (confirmed ?? false) {
          await controller.removeMember(widget.householdId, member.userId);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(householdControllerProvider);
    final activeId = ref.watch(
      sessionControllerProvider.select(
        (value) => value.user?.activeHouseholdId,
      ),
    );
    final household =
        state.household?.id == widget.householdId &&
            (!widget.settingsMode || activeId == widget.householdId)
        ? state.household
        : null;
    final invitation = state.invitation;
    final admin = household?.myRole == MemberRole.admin;
    return HouseholdLayout(
      title: HouseholdStrings.invite,
      step: widget.settingsMode ? null : 2,
      onBack: widget.settingsMode
          ? () => context.goNamed(RouteNames.householdSettings)
          : null,
      busy: state.busy,
      trailing: household != null && invitation != null
          ? HeaderIconButton(
              icon: AppIcons.share,
              tooltip: HouseholdStrings.share,
              onPressed: () => unawaited(_share(household, invitation)),
            )
          : null,
      footer: PrimaryButton(
        label: widget.settingsMode
            ? HouseholdStrings.done
            : HouseholdStrings.continueLabel,
        compact: true,
        onPressed: household == null || state.busy
            ? null
            : widget.settingsMode
            ? () => context.goNamed(RouteNames.householdSettings)
            : () => context.pushNamed(
                RouteNames.householdProfile,
                pathParameters: {'householdId': widget.householdId},
              ),
      ),
      child: widget.settingsMode && activeId != widget.householdId
          ? const Text(HouseholdStrings.inactiveHousehold)
          : household == null
          ? LoadPlaceholder(
              error: state.busy ? null : state.error,
              onRetry: () => unawaited(_load()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionLabel(
                  label: HouseholdStrings.members,
                  count: household.members.length,
                ),
                const SizedBox(height: 18),
                for (final (index, member) in household.members.indexed) ...[
                  if (index > 0) const SizedBox(height: 10),
                  MemberTile(
                    member: member,
                    index: index,
                    onAction: admin && !member.isMe && !state.busy
                        ? (action) => unawaited(_act(member, action))
                        : null,
                  ),
                ],
                const SizedBox(height: 18),
                if (admin) ...[
                  if (widget.settingsMode)
                    const InfoBanner(
                      message: HouseholdStrings.invitationRevocation,
                    ),
                  Semantics(
                    header: true,
                    child: const Text(
                      HouseholdStrings.shareTitle,
                      style: AppTypography.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (invitation != null)
                    InvitationCodeCard(
                      code: invitation.code,
                      busy: state.busy,
                      onCopy: () => unawaited(_copy(invitation.code)),
                      onShare: () => unawaited(_share(household, invitation)),
                      onRegenerate: state.busy
                          ? null
                          : () => unawaited(
                              ref
                                  .read(householdControllerProvider.notifier)
                                  .regenerate(widget.householdId),
                            ),
                    ),
                  const SizedBox(height: 18),
                ],
                InfoBanner(
                  icon: AppIcons.shieldLarge,
                  message: HouseholdStrings.adminHelp,
                ),
                if (state.error != null || state.savedPart.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  SaveFeedback(
                    error: state.error,
                    savedPart: state.savedPart,
                    onRetry: state.busy ? null : () => unawaited(_load()),
                  ),
                ],
              ],
            ),
    );
  }
}
