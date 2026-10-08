import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/field_message.dart';
import '../../../households/presentation/household_strings.dart';

class CapacityCard extends StatelessWidget {
  const CapacityCard({
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.title = HouseholdStrings.capacity,
    this.helpText = HouseholdStrings.capacityHelp,
    this.leading,
    this.divisions = 20,
    this.compact = false,
    super.key,
  });
  final int? value;
  final ValueChanged<int> onChanged;
  final String? errorText;
  final bool enabled;
  final String title;
  final String? helpText;
  final Widget? leading;
  final int divisions;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = value == null
        ? HouseholdStrings.capacityUnset
        : HouseholdStrings.percent(value!);
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 10)],
              Expanded(child: Text(title, style: AppTypography.titleSmall)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.end,
                  style: compact
                      ? AppTypography.titleSmall
                      : AppTypography.metric,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: AppColors.categoryOne,
              inactiveTrackColor: AppColors.chartTrack,
              disabledActiveTrackColor: AppColors.borderStrong,
              disabledInactiveTrackColor: AppColors.chartTrack,
              thumbShape: const _CapacityThumb(),
              tickMarkShape: SliderTickMarkShape.noTickMark,
              overlayColor: AppColors.focusRing,
              trackShape: const RoundedRectSliderTrackShape(),
              showValueIndicator: ShowValueIndicator.never,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Slider(
              value: (value ?? 0).toDouble(),
              max: 100,
              divisions: divisions,
              semanticFormatterCallback: (value) =>
                  HouseholdStrings.percent(value.round()),
              onChanged: enabled ? (next) => onChanged(next.round()) : null,
            ),
          ),
          if (!compact)
            const ExcludeSemantics(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      HouseholdStrings.less,
                      style: AppTypography.caption,
                    ),
                  ),
                  Text(HouseholdStrings.more, style: AppTypography.caption),
                ],
              ),
            ),
          if (helpText != null) ...[
            const SizedBox(height: 14),
            Text(
              helpText!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
          if (errorText != null) ...[
            const SizedBox(height: 8),
            FieldMessage.error(errorText!),
          ],
        ],
      ),
    );
  }
}

class _CapacityThumb extends SliderComponentShape {
  const _CapacityThumb();
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.square(24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    for (final shadow in AppShadows.elevationSmall) {
      canvas.drawCircle(center + shadow.offset, 12, shadow.toPaint());
    }
    canvas
      ..drawCircle(center, 12, Paint()..color = AppColors.surface)
      ..drawCircle(
        center,
        10.5,
        Paint()
          ..color = sliderTheme.activeTrackColor ?? AppColors.categoryOne
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
  }
}
