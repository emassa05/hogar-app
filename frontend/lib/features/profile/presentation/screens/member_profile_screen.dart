import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../households/domain/household_entities.dart';
import '../../../households/presentation/household_strings.dart';
import '../../../households/presentation/widgets/household_layout.dart';
import '../../domain/profile_entities.dart' as profile_entities;
import '../member_profile_provider.dart';
import '../widgets/availability_grid.dart';
import '../widgets/restriction_tile.dart';

class MemberProfileScreen extends ConsumerWidget {
  const MemberProfileScreen({
    required this.householdId,
    required this.userId,
    super.key,
  });
  final String householdId;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (householdId, userId);
    final profile = ref.watch(memberProfileProvider(key));
    final activeId = ref.watch(
      sessionControllerProvider.select(
        (value) => value.user?.activeHouseholdId,
      ),
    );
    final loaded =
        profile.isLoading || profile.hasError || activeId != householdId
        ? null
        : profile.asData?.value;
    return HouseholdLayout(
      title: loaded == null
          ? HouseholdStrings.memberProfile
          : loaded.isMe
          ? HouseholdStrings.ownProfile
          : HouseholdStrings.profileOf(loaded.displayName),
      onBack: () => context.goNamed(RouteNames.householdSettings),
      child: activeId != householdId
          ? const Text(HouseholdStrings.inactiveHousehold)
          : profile.when(
              skipLoadingOnRefresh: false,
              skipLoadingOnReload: false,
              loading: () => LoadPlaceholder(
                error: null,
                onRetry: () => ref.invalidate(memberProfileProvider(key)),
              ),
              error: (error, _) => LoadPlaceholder(
                error: asAppException(error),
                onRetry: () => ref.invalidate(memberProfileProvider(key)),
              ),
              data: (value) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (value.isMe)
                    Column(
                      children: [
                        AvatarCircle(
                          avatar: value.avatar,
                          name: value.name,
                          size: 140,
                        ),
                        const SizedBox(height: 16),
                        Text(value.name, style: AppTypography.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          value.role == MemberRole.admin
                              ? HouseholdStrings.roleAdmin
                              : HouseholdStrings.member,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text(HouseholdStrings.editProfile),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brand,
                            foregroundColor: AppColors.inverse,
                            textStyle: AppTypography.buttonCompact,
                            minimumSize: const Size(0, 48),
                          ),
                          onPressed: () => context.pushNamed(
                            RouteNames.profileEdit,
                            pathParameters: {'householdId': householdId},
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        AvatarCircle(
                          avatar: value.avatar,
                          name: value.name,
                          size: 64,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(value.name, style: AppTypography.titleLarge),
                              const SizedBox(height: 8),
                              Text(
                                value.role == MemberRole.admin
                                    ? HouseholdStrings.roleAdmin
                                    : HouseholdStrings.member,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        AvatarCircle(
                          avatar: value.avatar,
                          name: value.displayName,
                          size: 44,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                value.isMe
                                    ? HouseholdStrings.profilePreview
                                    : HouseholdStrings.memberProfilePreview,
                                style: AppTypography.caption,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                value.displayName,
                                style: AppTypography.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          HouseholdStrings.agreedCapacity,
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          value.approvedCapacityPercent == null
                              ? HouseholdStrings.capacityUnset
                              : HouseholdStrings.percent(
                                  value.approvedCapacityPercent!,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    HouseholdStrings.availability,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  AvailabilityGrid(
                    selected: value.availability.slots
                        .map((slot) => slot.identity)
                        .toSet(),
                    enabled: false,
                    onToggle: (_, _) {},
                  ),
                  for (final exception in value.availability.exceptions)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${displayDate(exception.date)} · ${switch (exception.period) {
                          profile_entities.DayPeriod.morning => HouseholdStrings.morning,
                          profile_entities.DayPeriod.afternoon => HouseholdStrings.afternoon,
                          profile_entities.DayPeriod.evening => HouseholdStrings.evening,
                          null => HouseholdStrings.allDay,
                        }} · ${exception.available ? HouseholdStrings.available : HouseholdStrings.unavailable}',
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    HouseholdStrings.restrictions,
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (value.restrictions.isEmpty)
                    Text(
                      value.isMe
                          ? HouseholdStrings.noRestrictions
                          : HouseholdStrings.noRegisteredRestrictions,
                    ),
                  for (final restriction in value.restrictions) ...[
                    RestrictionTile(restriction: restriction),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
    );
  }
}
