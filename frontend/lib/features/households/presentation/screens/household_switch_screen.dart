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
import '../../../../core/widgets/error_banner.dart';
import '../../../../core/widgets/info_banner.dart';
import '../household_controller.dart';
import '../household_strings.dart';
import '../widgets/household_layout.dart';

class HouseholdSwitchScreen extends ConsumerWidget {
  const HouseholdSwitchScreen({super.key});

  Future<void> _select(BuildContext context, WidgetRef ref, String id) async {
    final selected = await ref
        .read(householdControllerProvider.notifier)
        .openExisting(id);
    if (selected && context.mounted) {
      context.goNamed(RouteNames.householdSettings);
    }
  }

  void _open(BuildContext context, WidgetRef ref, String route) {
    ref.read(householdControllerProvider.notifier).reset();
    unawaited(context.pushNamed(route));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final households = ref.watch(householdListProvider);
    final activeId = ref.watch(
      sessionControllerProvider.select(
        (value) => value.user?.activeHouseholdId,
      ),
    );
    final flow = ref.watch(householdControllerProvider);
    ref.listen(householdListProvider, (previous, next) {
      if (next.asData?.value.isEmpty == true &&
          ref.read(sessionControllerProvider).user?.activeHouseholdId == null &&
          ref.read(householdControllerProvider).savedPart ==
              HouseholdStrings.leaveConfirmed) {
        final userId = ref.read(sessionControllerProvider).user?.id;
        final epoch = ref.read(sessionControllerProvider.notifier).epoch;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted &&
              ref.read(sessionControllerProvider).user?.id == userId &&
              ref.read(sessionControllerProvider.notifier).epoch == epoch &&
              ref.read(sessionControllerProvider).user?.activeHouseholdId ==
                  null &&
              ref.read(householdListProvider).asData?.value.isEmpty == true) {
            context.goNamed(RouteNames.householdChoice);
          }
        });
      }
    });
    return HouseholdLayout(
      title: HouseholdStrings.myHouseholds,
      busy: flow.busy,
      onBack: () => context.goNamed(RouteNames.householdSettings),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (flow.error != null) ...[
            ErrorBanner(error: flow.error!),
            const SizedBox(height: 16),
          ],
          if (flow.savedPart == HouseholdStrings.leaveConfirmed) ...[
            const InfoBanner(message: HouseholdStrings.leaveConfirmed),
            const SizedBox(height: 16),
          ],
          if (flow.busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ],
          households.when(
            skipLoadingOnRefresh: false,
            skipLoadingOnReload: false,
            loading: () => LoadPlaceholder(
              error: null,
              onRetry: () => ref.invalidate(householdListProvider),
            ),
            error: (error, _) => LoadPlaceholder(
              error: asAppException(error),
              onRetry: () => ref.invalidate(householdListProvider),
            ),
            data: (values) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  HouseholdStrings.householdCount(values.length),
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 16),
                if (values.isEmpty)
                  const AppCard(child: Text(HouseholdStrings.noHouseholds)),
                for (final household in values) ...[
                  Semantics(
                    selected: household.id == activeId,
                    child: AppCard(
                      borderColor: household.id == activeId
                          ? AppColors.brand
                          : AppColors.border,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            household.name,
                            style: AppTypography.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            HouseholdStrings.memberCount(household.memberCount),
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          SecondaryButton(
                            label: household.id == activeId
                                ? HouseholdStrings.activeHousehold
                                : HouseholdStrings.switchHousehold,
                            onPressed: flow.busy
                                ? null
                                : () => household.id == activeId
                                      ? context.goNamed(
                                          RouteNames.householdSettings,
                                        )
                                      : _select(context, ref, household.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const InfoBanner(message: HouseholdStrings.profileLocal),
          const SizedBox(height: 16),
          SecondaryButton(
            label: HouseholdStrings.create,
            onPressed: flow.busy
                ? null
                : () => _open(context, ref, RouteNames.householdCreate),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: HouseholdStrings.join,
            onPressed: flow.busy
                ? null
                : () => _open(context, ref, RouteNames.householdJoin),
          ),
        ],
      ),
    );
  }
}
