import 'package:flutter/material.dart';

import '../motion/pressable_scale.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.radius = AppRadius.large,
    this.shadows,
    super.key,
  });
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final double radius;
  final List<BoxShadow>? shadows;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
      boxShadow: shadows,
    ),
    child: child,
  );
}

class IconTile extends StatelessWidget {
  const IconTile({
    required this.icon,
    required this.background,
    required this.color,
    this.size = 32,
    this.iconSize,
    this.radius = 10,
    super.key,
  });
  final AppIcons icon;
  final Color background;
  final Color color;
  final double size;
  final double? iconSize;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: AppIcon(icon, size: iconSize, color: color),
  );
}

class OptionCard extends StatelessWidget {
  const OptionCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.description,
    this.onPressed,
    super.key,
  });
  final AppIcons icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: '$title. $description',
    excludeSemantics: true,
    child: PressableScale(
      enabled: onPressed != null,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconTile(
                      icon: icon,
                      background: iconBackground,
                      color: iconColor,
                      size: 44,
                      iconSize: 24,
                      radius: 13,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(title, style: AppTypography.titleMedium),
                    ),
                    const SizedBox(width: 12),
                    const AppIcon(
                      AppIcons.chevronRight,
                      color: AppColors.iconTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
