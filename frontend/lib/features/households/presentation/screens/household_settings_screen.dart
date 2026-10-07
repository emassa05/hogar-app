import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../domain/household_entities.dart';
import '../household_controller.dart';
import '../household_strings.dart';
import '../widgets/household_layout.dart';
import '../widgets/member_tile.dart';

class HouseholdSettingsScreen extends ConsumerWidget {
  const HouseholdSettingsScreen({super.key});

  Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    String id,
    Member member,
    MemberAction action,
  ) async {
    final actorId = ref.read(sessionControllerProvider).user?.id;
    final actorEpoch = ref.read(sessionControllerProvider.notifier).epoch;
    if (action == MemberAction.remove) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(HouseholdStrings.removeQuestion),
          content: Text(
            '${member.displayName}\n${HouseholdStrings.historyPreserved}',
          ),
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
      if (confirmed != true || !context.mounted) return;
    }
    if (ref.read(sessionControllerProvider).user?.activeHouseholdId != id ||
        ref.read(sessionControllerProvider).user?.id != actorId ||
        ref.read(sessionControllerProvider.notifier).epoch != actorEpoch) {
      return;
    }
    final controller = ref.read(householdControllerProvider.notifier);
    if (!await controller.load(id, includeInvitation: false)) return;
    if (!context.mounted) return;
    if (ref.read(sessionControllerProvider).user?.activeHouseholdId != id ||
        ref.read(sessionControllerProvider).user?.id != actorId ||
        ref.read(sessionControllerProvider.notifier).epoch != actorEpoch) {
      return;
    }
    final current = ref.read(householdControllerProvider).household;
    if (current?.myRole != MemberRole.admin) return;
    switch (action) {
      case MemberAction.makeAdmin:
        await controller.changeRole(id, member.userId, MemberRole.admin);
      case MemberAction.makeMember:
        if (member.isMe &&
            current!.members
                    .where((value) => value.role == MemberRole.admin)
                    .length ==
                1) {
          return;
        }
        await controller.changeRole(id, member.userId, MemberRole.member);
      case MemberAction.remove:
        if (!member.isMe) await controller.removeMember(id, member.userId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeHouseholdProvider);
    final flow = ref.watch(householdControllerProvider);
    final activeId = ref.watch(
      sessionControllerProvider.select(
        (value) => value.user?.activeHouseholdId,
      ),
    );
    final household =
        flow.savedPart.isNotEmpty && flow.household?.id == activeId
        ? AsyncData<HouseholdDetail?>(flow.household)
        : active;
    final members = household.isLoading || household.hasError
        ? null
        : household.asData?.value?.members;
    final ownMembers = members?.where((member) => member.isMe);
    final ownMember = ownMembers == null || ownMembers.isEmpty
        ? null
        : ownMembers.first;
    return HouseholdLayout(
      title: HouseholdStrings.household,
      onBack: () => context.goNamed(RouteNames.home),
      busy: flow.busy,
      trailing: ownMember == null
          ? null
          : InkWell(
              onTap: flow.busy
                  ? null
                  : () => context.pushNamed(
                      RouteNames.memberProfile,
                      pathParameters: {
                        'householdId': household.requireValue!.id,
                        'userId': 'me',
                      },
                    ),
              child: AvatarCircle(
                avatar: ownMember.avatar,
                name: ownMember.displayName,
                size: 40,
              ),
            ),
      child: household.when(
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: false,
        loading: () => LoadPlaceholder(
          error: null,
          onRetry: () => ref.invalidate(activeHouseholdProvider),
        ),
        error: (error, _) => LoadPlaceholder(
          error: asAppException(error),
          onRetry: () => ref.invalidate(activeHouseholdProvider),
        ),
        data: (value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OptionCard(
                icon: AppIcons.home,
                iconBackground: AppColors.brandSubtle,
                iconColor: AppColors.iconBrand,
                title: value?.name ?? HouseholdStrings.myHouseholds,
                description: value == null
                    ? HouseholdStrings.noActiveHousehold
                    : HouseholdStrings.memberCount(value.members.length),
                onPressed: flow.busy
                    ? null
                    : () => context.pushNamed(RouteNames.householdSwitch),
              ),
              if (value != null) ...[
                const SizedBox(height: 16),
                const Text(
                  HouseholdStrings.members,
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 16),
                if (value.members.isEmpty)
                  const AppCard(child: Text(HouseholdStrings.noMembers)),
                for (final (index, member) in value.members.indexed) ...[
                  if (index > 0) const SizedBox(height: 16),
                  MemberTile(
                    member: member,
                    index: index,
                    canRemove: !member.isMe,
                    canChangeRole:
                        !member.isMe ||
                        value.members
                                .where(
                                  (value) => value.role == MemberRole.admin,
                                )
                                .length >
                            1,
                    onAction:
                        value.myRole == MemberRole.admin &&
                            !flow.busy &&
                            (!member.isMe ||
                                value.members
                                        .where(
                                          (value) =>
                                              value.role == MemberRole.admin,
                                        )
                                        .length >
                                    1)
                        ? (action) => unawaited(
                            _act(context, ref, value.id, member, action),
                          )
                        : null,
                    onPressed: flow.busy
                        ? null
                        : () => context.pushNamed(
                            RouteNames.memberProfile,
                            pathParameters: {
                              'householdId': value.id,
                              'userId': member.isMe ? 'me' : member.userId,
                            },
                          ),
                  ),
                ],
                if (value.myRole == MemberRole.admin) ...[
                  const SizedBox(height: 16),
                  SecondaryButton(
                    label: HouseholdStrings.editHousehold,
                    onPressed: flow.busy
                        ? null
                        : () => context.pushNamed(
                            RouteNames.householdEdit,
                            pathParameters: {'householdId': value.id},
                          ),
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: HouseholdStrings.invite,
                    onPressed: flow.busy
                        ? null
                        : () => context.pushNamed(
                            RouteNames.settingsInvite,
                            pathParameters: {'householdId': value.id},
                          ),
                  ),
                ],
              ],
              if (flow.error != null || flow.savedPart.isNotEmpty) ...[
                const SizedBox(height: 16),
                SaveFeedback(
                  error: flow.error,
                  savedPart: flow.savedPart,
                  onRetry: flow.busy || activeId == null
                      ? null
                      : () => unawaited(
                          ref
                              .read(householdControllerProvider.notifier)
                              .refreshConfirmedHousehold(activeId),
                        ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
