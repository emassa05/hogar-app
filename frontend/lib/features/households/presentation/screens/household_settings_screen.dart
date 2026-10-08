import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/api_error_code.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../capacity/presentation/capacity_strings.dart';
import '../../../notifications/presentation/notification_strings.dart';
import '../../domain/household_entities.dart';
import '../household_controller.dart';
import '../household_strings.dart';
import '../widgets/household_layout.dart';
import '../widgets/household_settings_row.dart';
import '../widgets/member_tile.dart';

class HouseholdSettingsScreen extends ConsumerWidget {
  const HouseholdSettingsScreen({super.key});

  Future<void> _leave(
    BuildContext context,
    WidgetRef ref,
    HouseholdDetail household,
  ) async {
    final userId = ref.read(sessionControllerProvider).user?.id;
    final epoch = ref.read(sessionControllerProvider.notifier).epoch;
    var identityChanged = false;
    final subscription = ref.listenManual(sessionControllerProvider, (
      previous,
      next,
    ) {
      if (next.user?.id != userId ||
          next.user?.activeHouseholdId != household.id) {
        identityChanged = true;
      }
    });
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text(HouseholdStrings.leaveQuestion),
        content: Text('${household.name}\n${HouseholdStrings.leaveHelp}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(HouseholdStrings.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(HouseholdStrings.leaveHousehold(household.name)),
          ),
        ],
      ),
    );
    subscription.close();
    if (confirmed != true ||
        identityChanged ||
        !context.mounted ||
        ref.read(sessionControllerProvider).user?.id != userId ||
        ref.read(sessionControllerProvider).user?.activeHouseholdId !=
            household.id ||
        ref.read(sessionControllerProvider.notifier).epoch != epoch) {
      return;
    }
    final left = await ref
        .read(householdControllerProvider.notifier)
        .leave(household.id);
    if (left &&
        context.mounted &&
        ref.read(sessionControllerProvider).user?.id == userId &&
        ref.read(sessionControllerProvider.notifier).epoch == epoch &&
        ref.read(sessionControllerProvider).user?.activeHouseholdId == null) {
      context.goNamed(RouteNames.householdSwitch);
    }
  }

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
    final membersKey = GlobalKey();
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
              AppCard(
                padding: EdgeInsets.zero,
                child: HouseholdSettingsRow(
                  icon: AppIcons.home,
                  title: value?.name ?? HouseholdStrings.myHouseholds,
                  description: value == null
                      ? HouseholdStrings.noActiveHousehold
                      : HouseholdStrings.memberCount(value.members.length),
                  onPressed: flow.busy
                      ? null
                      : () => context.pushNamed(RouteNames.householdSwitch),
                ),
              ),
              const SizedBox(height: 16),
              if (value != null) ...[
                SectionLabel(
                  key: membersKey,
                  label: HouseholdStrings.members,
                  count: value.members.length,
                ),
                const SizedBox(height: 16),
                if (value.members.isEmpty)
                  const AppCard(child: Text(HouseholdStrings.noMembers)),
                for (final (index, member) in value.members.indexed) ...[
                  if (index > 0) const SizedBox(height: 16),
                  MemberTile(
                    member: member,
                    index: index,
                    showCharacter: true,
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
              ],
              const SizedBox(height: 16),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    HouseholdSettingsRow(
                      title: NotificationStrings.entry,
                      icon: AppIcons.alertCircle,
                      onPressed: flow.busy
                          ? null
                          : () => context.pushNamed(
                              RouteNames.notificationSettings,
                            ),
                    ),
                    if (value != null) ...[
                      const Divider(height: 1),
                      HouseholdSettingsRow(
                        title: CapacityStrings.entry,
                        icon: AppIcons.handHeart,
                        onPressed: flow.busy
                            ? null
                            : () => context.pushNamed(
                                RouteNames.capacity,
                                pathParameters: {'householdId': value.id},
                              ),
                      ),
                    ],
                    if (value?.myRole == MemberRole.admin) ...[
                      const Divider(height: 1),
                      HouseholdSettingsRow(
                        title: HouseholdStrings.editHousehold,
                        icon: AppIcons.home,
                        onPressed: flow.busy
                            ? null
                            : () => context.pushNamed(
                                RouteNames.householdEdit,
                                pathParameters: {'householdId': value!.id},
                              ),
                      ),
                      const Divider(height: 1),
                      HouseholdSettingsRow(
                        title: HouseholdStrings.invite,
                        icon: AppIcons.plus,
                        onPressed: flow.busy
                            ? null
                            : () => context.pushNamed(
                                RouteNames.settingsInvite,
                                pathParameters: {'householdId': value!.id},
                              ),
                      ),
                    ],
                    const Divider(height: 1),
                    HouseholdSettingsRow(
                      title: HouseholdStrings.myHouseholds,
                      icon: AppIcons.building,
                      onPressed: flow.busy
                          ? null
                          : () => context.pushNamed(RouteNames.householdSwitch),
                    ),
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(height: 24),
                const Text(
                  HouseholdStrings.sensitiveArea,
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 12),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: flow.busy
                      ? null
                      : () => _leave(context, ref, value),
                  child: Text(HouseholdStrings.leaveHousehold(value.name)),
                ),
                if (flow.error case ApiException(
                  code: ApiErrorCode.lastAdminMustTransfer,
                )) ...[
                  const Text(HouseholdStrings.transferBeforeLeaving),
                  TextButton(
                    onPressed: () {
                      final target = membersKey.currentContext;
                      if (target != null) {
                        unawaited(Scrollable.ensureVisible(target));
                      }
                    },
                    child: const Text(HouseholdStrings.manageMembers),
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
                      : flow.savedPart == HouseholdStrings.leaveUncertain &&
                            value != null
                      ? () => unawaited(_leave(context, ref, value))
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
