import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';

class HouseholdSettingsRow extends StatelessWidget {
  const HouseholdSettingsRow({
    required this.title,
    required this.icon,
    this.description,
    this.supportingText,
    this.onPressed,
    super.key,
  });
  final String title;
  final AppIcons icon;
  final String? description;
  final String? supportingText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconTile(
                  icon: icon,
                  background: AppColors.brandSubtle,
                  color: AppColors.iconBrand,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.titleSmall),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(description!, style: AppTypography.bodySmall),
                      ],
                      if (supportingText != null) ...[
                        const SizedBox(height: 4),
                        Text(supportingText!, style: AppTypography.caption),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const AppIcon(
                  AppIcons.chevronRight,
                  color: AppColors.iconTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
