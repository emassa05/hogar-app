import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../domain/capacity_entities.dart';
import '../capacity_strings.dart';

class CapacityDistributionCard extends StatelessWidget {
  const CapacityDistributionCard({
    required this.title,
    required this.distribution,
    super.key,
  });
  final String title;
  final CapacityDistribution distribution;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: AppTypography.titleSmall),
        ),
        const SizedBox(height: 8),
        Text(
          CapacityStrings.effective(distribution.effectiveFrom),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: 8),
        Text(CapacityStrings.preview, style: AppTypography.caption),
        const SizedBox(height: 12),
        ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  for (final (index, allocation)
                      in distribution.allocations.indexed)
                    if (allocation.percent > 0)
                      Expanded(
                        flex: allocation.percent,
                        child: ColoredBox(
                          color: _colors[index % _colors.length],
                          child: const SizedBox.expand(),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final allocation in distribution.allocations) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                AvatarCircle(
                  avatar: allocation.member.avatar,
                  name: allocation.member.displayName,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${allocation.member.displayName}${allocation.member.isActive ? '' : ' · ${CapacityStrings.former}'}',
                    style: AppTypography.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    CapacityStrings.percent(allocation.percent),
                    style: AppTypography.titleSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          CapacityStrings.approver(distribution.approvedBy.displayName),
          style: AppTypography.caption,
        ),
        const SizedBox(height: 4),
        Text(
          CapacityStrings.approvedAt(
            DateFormat(
              'dd/MM/yyyy HH:mm',
            ).format(distribution.approvedAt.toUtc()),
          ),
          style: AppTypography.caption,
        ),
      ],
    ),
  );

  static const _colors = [
    AppColors.categoryOne,
    AppColors.categoryTwo,
    AppColors.categoryThree,
    AppColors.categoryFour,
    AppColors.categoryFive,
    AppColors.categorySix,
  ];
}
