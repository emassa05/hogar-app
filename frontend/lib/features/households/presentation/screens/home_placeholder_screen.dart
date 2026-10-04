import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../household_controller.dart';
import '../household_strings.dart';
import '../widgets/household_layout.dart';

class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final household = ref.watch(activeHouseholdProvider);
    return HouseholdLayout(
      title: HouseholdStrings.home,
      showBack: false,
      child: household.when(
        skipLoadingOnRefresh: false,
        loading: () => const LoadPlaceholder(error: null, onRetry: _noop),
        error: (error, _) => LoadPlaceholder(
          error: asAppException(error),
          onRetry: () => ref.invalidate(activeHouseholdProvider),
        ),
        data: (value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const IconTile(
                  icon: AppIcons.home,
                  background: AppColors.brandSubtle,
                  color: AppColors.iconBrand,
                  size: 44,
                  iconSize: 24,
                  radius: 13,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      value?.name ?? HouseholdStrings.home,
                      style: AppTypography.display,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              HouseholdStrings.homeSoon,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            if (value != null) ...[
              const SizedBox(height: 8),
              Text(
                HouseholdStrings.memberCount(value.members.length),
                style: AppTypography.dataSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void _noop() {}
