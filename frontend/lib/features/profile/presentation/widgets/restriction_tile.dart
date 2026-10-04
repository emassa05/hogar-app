import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../households/presentation/household_strings.dart';
import '../../domain/profile_entities.dart';

enum RestrictionAction { edit, remove }

String displayDate(String isoDate) {
  final parts = isoDate.split('-');
  return parts.length == 3 ? '${parts[2]}/${parts[1]}/${parts[0]}' : isoDate;
}

class RestrictionTile extends StatelessWidget {
  const RestrictionTile({required this.restriction, this.onAction, super.key});
  final Restriction restriction;
  final ValueChanged<RestrictionAction>? onAction;

  @override
  Widget build(BuildContext context) {
    final permanent = restriction.kind == RestrictionKind.permanent;
    final kindLabel = permanent
        ? HouseholdStrings.permanent
        : HouseholdStrings.temporaryUntil(
            displayDate(restriction.endsOn ?? restriction.startsOn),
          );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          IconTile(
            icon: permanent ? AppIcons.ban : AppIcons.clockLarge,
            background: permanent
                ? AppColors.dangerSubtle
                : AppColors.warningSubtle,
            color: permanent ? AppColors.iconDanger : AppColors.iconWarning,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restriction.targetName,
                    style: AppTypography.bodyMediumStrong,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    kindLabel,
                    style: AppTypography.caption.copyWith(
                      color: permanent ? AppColors.danger : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onAction != null)
            PopupMenuButton<RestrictionAction>(
              tooltip: HouseholdStrings.restrictionOptions(
                restriction.targetName,
              ),
              icon: const AppIcon(AppIcons.more, color: AppColors.iconTertiary),
              onSelected: onAction,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: RestrictionAction.edit,
                  child: Text(
                    HouseholdStrings.editRestriction,
                    style: AppTypography.bodyMediumStrong,
                  ),
                ),
                PopupMenuItem(
                  value: RestrictionAction.remove,
                  child: Text(
                    HouseholdStrings.removeRestriction,
                    style: AppTypography.bodyMediumStrong.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class DashedAddButton extends StatelessWidget {
  const DashedAddButton({required this.label, this.onPressed, super.key});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: label,
    excludeSemantics: true,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: CustomPaint(
        painter: _DashedBorder(
          color: onPressed == null ? AppColors.border : AppColors.borderStrong,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppIcon(AppIcons.plus, color: AppColors.iconPrimary),
                const SizedBox(width: 8),
                Flexible(child: Text(label, style: AppTypography.labelLarge)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder({required this.color});
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.5),
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, Paint()..color = AppColors.surface);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in (Path()..addRRect(rect)).computeMetrics()) {
      for (var distance = 0.0; distance < metric.length; distance += 7) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder oldDelegate) => oldDelegate.color != color;
}
