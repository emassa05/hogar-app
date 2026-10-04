import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

enum FieldMessageTone { helper, error, success }

class FieldMessage extends StatelessWidget {
  const FieldMessage({
    required this.text,
    this.tone = FieldMessageTone.helper,
    this.icon,
    this.trailing,
    super.key,
  });
  const FieldMessage.helper(this.text, {this.icon, this.trailing, super.key})
    : tone = FieldMessageTone.helper;
  const FieldMessage.error(this.text, {this.trailing, super.key})
    : tone = FieldMessageTone.error,
      icon = AppIcons.alertCircle;
  const FieldMessage.success(this.text, {this.trailing, super.key})
    : tone = FieldMessageTone.success,
      icon = AppIcons.checkCircle;
  final String text;
  final FieldMessageTone tone;
  final AppIcons? icon;
  final Widget? trailing;

  Color get _textColor => switch (tone) {
    FieldMessageTone.helper => AppColors.textTertiary,
    FieldMessageTone.error => AppColors.danger,
    FieldMessageTone.success => AppColors.success,
  };

  Color get _iconColor => switch (tone) {
    FieldMessageTone.helper => AppColors.iconTertiary,
    FieldMessageTone.error => AppColors.iconDanger,
    FieldMessageTone.success => AppColors.iconSuccess,
  };

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: tone != FieldMessageTone.helper,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: AppIcon(icon!, size: 16, color: _iconColor),
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(color: _textColor),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}
