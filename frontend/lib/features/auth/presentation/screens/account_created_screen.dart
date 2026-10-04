import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/motion/motion_reveal.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/accent_title.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../auth_controller.dart';
import '../auth_strings.dart';

class AccountCreatedScreen extends ConsumerWidget {
  const AccountCreatedScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionControllerProvider).user;
    return AppScaffold(
      sky: true,
      footer: PrimaryButton(
        label: AuthStrings.start,
        icon: Icons.arrow_forward,
        onPressed: () {
          ref.read(authControllerProvider.notifier).dismissCelebration();
          context.goNamed(RouteNames.householdChoice);
        },
      ),
      child: Column(
        children: [
          MotionReveal(
            delight: true,
            child: Image.asset(
              'assets/images/account-created-celebration.png',
              height: 270,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AvatarCircle(
                  avatar: user?.avatar,
                  name: user?.name ?? '',
                  size: 40,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? '', style: AppTypography.labelLarge),
                      Text(user?.phone ?? '', style: AppTypography.dataSmall),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.check_circle, color: AppColors.successSurface),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AccentTitle(
            text: AuthStrings.createdTitle,
            accent: AuthStrings.createdAccent,
            suffix: '\n${user?.name ?? ''}!',
            centered: true,
          ),
          const SizedBox(height: 12),
          const Text(
            AuthStrings.createdBody,
            style: AppTypography.introduction,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(AuthStrings.next, style: AppTypography.dataSmall),
                for (
                  var index = 0;
                  index < AuthStrings.nextSteps.length;
                  index++
                )
                  MotionReveal(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.brandSubtle,
                            child: Text(
                              '${index + 1}',
                              style: AppTypography.dataSmall.copyWith(
                                color: AppColors.brand,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AuthStrings.nextSteps[index],
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
