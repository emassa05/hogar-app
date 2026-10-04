import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class OverlineDivider extends StatelessWidget {
  const OverlineDivider({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    label: label,
    excludeSemantics: true,
    child: Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderSubtle)),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.overline),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppColors.borderSubtle)),
      ],
    ),
  );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    required this.label,
    this.count,
    this.trailing,
    super.key,
  });
  final String label;
  final int? count;
  final String? trailing;
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Row(
      children: [
        Text(label, style: AppTypography.labelSmall),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.neutral,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '$count',
              style: AppTypography.dataSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppColors.borderSubtle)),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          Text(trailing!, style: AppTypography.dataSmall),
        ],
      ],
    ),
  );
}

class AppTag extends StatelessWidget {
  const AppTag({
    required this.label,
    this.background = AppColors.brandSubtle,
    this.foreground = AppColors.brand,
    super.key,
  });
  final String label;
  final Color background;
  final Color foreground;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: AppTypography.overline.copyWith(
        letterSpacing: 0,
        color: foreground,
      ),
    ),
  );
}
