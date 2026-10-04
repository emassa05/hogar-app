import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

enum BannerTone { info, warning, danger, success }

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    required this.message,
    this.title,
    this.tone = BannerTone.info,
    this.icon = AppIcons.info,
    this.action,
    super.key,
  });
  final String message;
  final String? title;
  final BannerTone tone;
  final AppIcons icon;
  final Widget? action;

  Color get _background => switch (tone) {
    BannerTone.info => AppColors.brandSubtle,
    BannerTone.warning => AppColors.warningSubtle,
    BannerTone.danger => AppColors.dangerSubtle,
    BannerTone.success => AppColors.successSubtle,
  };

  Color get _accent => switch (tone) {
    BannerTone.info => AppColors.brand,
    BannerTone.warning => AppColors.warning,
    BannerTone.danger => AppColors.danger,
    BannerTone.success => AppColors.success,
  };

  Color get _iconColor => switch (tone) {
    BannerTone.info => AppColors.iconBrand,
    BannerTone.warning => AppColors.iconWarning,
    BannerTone.danger => AppColors.iconDanger,
    BannerTone.success => AppColors.iconSuccess,
  };

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    liveRegion: tone == BannerTone.danger,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon, size: 20, color: _iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTypography.labelLarge.copyWith(color: _accent),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: tone == BannerTone.danger
                        ? AppColors.danger
                        : AppColors.textSecondary,
                  ),
                ),
                if (action != null) ...[const SizedBox(height: 4), action!],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
