import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_buttons.dart';
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
    return HouseholdLayout(
      title: HouseholdStrings.profile,
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
                  AppCard(
                    child: Column(
                      children: [
                        AvatarCircle(
                          avatar: value.avatar,
                          name: value.name,
                          size: value.isMe ? 140 : 64,
                        ),
                        const SizedBox(height: 16),
                        Text(value.name, style: AppTypography.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          value.role == MemberRole.admin
                              ? HouseholdStrings.roleAdmin
                              : HouseholdStrings.member,
                        ),
                        if (value.isMe) ...[
                          const SizedBox(height: 16),
                          SecondaryButton(
                            label: HouseholdStrings.editProfile,
                            expand: false,
                            onPressed: () => context.pushNamed(
                              RouteNames.profileEdit,
                              pathParameters: {'householdId': householdId},
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          HouseholdStrings.profilePreview,
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          value.displayName,
                          style: AppTypography.titleLarge,
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
                    const Text(HouseholdStrings.noRestrictions),
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
