import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    required this.message,
    this.title,
    this.warning = false,
    this.icon = Icons.info_outline,
    super.key,
  });
  final String message;
  final String? title;
  final bool warning;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: warning ? AppColors.warningSubtle : AppColors.brandSubtle,
      borderRadius: BorderRadius.circular(AppRadius.large),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: warning ? AppColors.iconWarning : AppColors.brand,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: AppTypography.labelLarge.copyWith(
                    color: warning ? AppColors.warning : AppColors.brand,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(message, style: AppTypography.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}
