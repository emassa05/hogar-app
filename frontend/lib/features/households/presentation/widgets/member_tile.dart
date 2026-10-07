import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../domain/household_entities.dart';
import '../household_strings.dart';

enum MemberAction { makeAdmin, makeMember, remove }

const _palette = [
  (
    AppColors.categoryOneSubtle,
    AppColors.categoryOne,
    AppColors.categoryOneText,
  ),
  (
    AppColors.categoryTwoSubtle,
    AppColors.categoryTwo,
    AppColors.categoryTwoText,
  ),
  (
    AppColors.categoryFourSubtle,
    AppColors.categoryFour,
    AppColors.categoryFourText,
  ),
  (
    AppColors.categorySixSubtle,
    AppColors.categorySix,
    AppColors.categorySixText,
  ),
];

class MemberTile extends StatelessWidget {
  const MemberTile({
    required this.member,
    required this.index,
    this.onAction,
    this.onPressed,
    this.canRemove = true,
    this.canChangeRole = true,
    super.key,
  });
  final Member member;
  final int index;
  final ValueChanged<MemberAction>? onAction;
  final VoidCallback? onPressed;
  final bool canRemove;
  final bool canChangeRole;

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground) = _palette[index % _palette.length];
    final admin = member.role == MemberRole.admin;
    final roleLabel = admin
        ? HouseholdStrings.roleAdmin
        : HouseholdStrings.member;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              MergeSemantics(
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                    border: Border.all(color: border, width: 1.5),
                  ),
                  child: ExcludeSemantics(
                    child: Text(
                      AvatarCircle.initialsOf(member.displayName),
                      textScaler: TextScaler.noScaling,
                      style: AppTypography.labelMedium.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.displayName,
                              style: AppTypography.titleSmall,
                            ),
                          ),
                          if (member.isMe) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brandSubtle,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                HouseholdStrings.you,
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.brand,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (admin) ...[
                            const AppIcon(
                              AppIcons.shield,
                              color: AppColors.iconBrand,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              roleLabel,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (onAction != null)
                PopupMenuButton<MemberAction>(
                  tooltip: HouseholdStrings.memberOptions(member.displayName),
                  icon: const AppIcon(
                    AppIcons.more,
                    color: AppColors.iconTertiary,
                  ),
                  onSelected: onAction,
                  itemBuilder: (context) => [
                    if (canChangeRole)
                      PopupMenuItem(
                        value: admin
                            ? MemberAction.makeMember
                            : MemberAction.makeAdmin,
                        child: Text(
                          admin
                              ? HouseholdStrings.makeMember
                              : HouseholdStrings.makeAdmin,
                          style: AppTypography.bodyMediumStrong,
                        ),
                      ),
                    if (canRemove)
                      PopupMenuItem(
                        value: MemberAction.remove,
                        child: Text(
                          HouseholdStrings.removeMember,
                          style: AppTypography.bodyMediumStrong.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
