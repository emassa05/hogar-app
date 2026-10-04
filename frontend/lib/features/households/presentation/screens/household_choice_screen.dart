import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/info_banner.dart';
import '../household_controller.dart';
import '../household_strings.dart';
import '../widgets/household_layout.dart';

class HouseholdChoiceScreen extends ConsumerWidget {
  const HouseholdChoiceScreen({super.key});

  void _open(BuildContext context, WidgetRef ref, String route) {
    ref.read(householdControllerProvider.notifier).reset();
    unawaited(context.pushNamed(route));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => HouseholdLayout(
    title: HouseholdStrings.start,
    showBack: context.canPop(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: const Text(
            HouseholdStrings.chooseTitle,
            style: AppTypography.display,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          HouseholdStrings.chooseBody,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        OptionCard(
          icon: AppIcons.home,
          iconBackground: AppColors.brandSubtle,
          iconColor: AppColors.iconBrand,
          title: HouseholdStrings.create,
          description: HouseholdStrings.createBody,
          onPressed: () => _open(context, ref, RouteNames.householdCreate),
        ),
        const SizedBox(height: 16),
        OptionCard(
          icon: AppIcons.key,
          iconBackground: AppColors.discoverSubtle,
          iconColor: AppColors.iconDiscover,
          title: HouseholdStrings.join,
          description: HouseholdStrings.joinBody,
          onPressed: () => _open(context, ref, RouteNames.householdJoin),
        ),
        const SizedBox(height: 16),
        const InfoBanner(message: HouseholdStrings.profileLocal),
      ],
    ),
  );
}
