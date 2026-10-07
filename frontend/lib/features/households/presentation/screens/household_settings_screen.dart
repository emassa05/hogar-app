import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../household_controller.dart';
import '../household_strings.dart';
import '../widgets/household_layout.dart';
import '../widgets/member_tile.dart';

class HouseholdSettingsScreen extends ConsumerWidget {
  const HouseholdSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final household = ref.watch(activeHouseholdProvider);
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
      trailing: ownMember == null
          ? null
          : AvatarCircle(
              avatar: ownMember.avatar,
              name: ownMember.displayName,
              size: 40,
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
                onPressed: () => context.pushNamed(RouteNames.householdSwitch),
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
                  MemberTile(member: member, index: index),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}
