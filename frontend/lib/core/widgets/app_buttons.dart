import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../motion/pressable_scale.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';
import 'app_icon.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    this.compact = false,
    this.trailingIcon,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool compact;
  final AppIcons? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final active = enabled || loading;
    final foreground = active ? AppColors.inverse : AppColors.textDisabled;
    final button = _ButtonFrame(
      label: label,
      loading: loading,
      onPressed: enabled ? onPressed : null,
      minHeight: compact ? 48 : 56,
      padding: EdgeInsets.symmetric(horizontal: compact ? 20 : 24),
      radius: compact ? AppRadius.medium : AppRadius.pill,
      color: active ? AppColors.brand : AppColors.neutral,
      shadows: active && !compact ? AppShadows.primaryAction : null,
      child: _ButtonContent(
        label: label,
        loading: loading,
        color: foreground,
        style: compact ? AppTypography.buttonCompact : AppTypography.button,
        trailing: trailingIcon,
        iconSize: 20,
        gap: 10,
      ),
    );
    return SizedBox(width: double.infinity, child: button);
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    this.pill = false,
    this.expand = true,
    this.leadingIcon,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool pill;
  final bool expand;
  final AppIcons? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final button = _ButtonFrame(
      label: label,
      loading: loading,
      onPressed: enabled ? onPressed : null,
      minHeight: 48,
      padding: pill
          ? const EdgeInsets.only(left: 20, right: 22)
          : const EdgeInsets.symmetric(horizontal: 20),
      radius: pill ? AppRadius.pill : AppRadius.medium,
      color: AppColors.surface,
      border: Border.all(
        color: pill || !enabled ? AppColors.border : AppColors.borderStrong,
      ),
      shadows: pill && enabled ? AppShadows.outlinedPill : null,
      child: _ButtonContent(
        label: label,
        loading: loading,
        color: enabled || loading
            ? AppColors.textPrimary
            : AppColors.textDisabled,
        style: AppTypography.buttonCompact,
        leading: leadingIcon,
        iconSize: 18,
        gap: 8,
      ),
    );
    return expand
        ? SizedBox(width: double.infinity, child: button)
        : Center(child: button);
  }
}

class TextLinkButton extends StatelessWidget {
  const TextLinkButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    this.style = AppTypography.link,
    this.underline = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final TextStyle style;
  final bool underline;
  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return _ButtonFrame(
      label: label,
      loading: loading,
      onPressed: enabled ? onPressed : null,
      minHeight: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      radius: AppRadius.medium,
      color: Colors.transparent,
      child: _ButtonContent(
        label: label,
        loading: loading,
        color: enabled || loading
            ? style.color ?? AppColors.brand
            : AppColors.textDisabled,
        style: style.copyWith(
          decoration: underline ? TextDecoration.underline : null,
          decorationColor: style.color,
        ),
        iconSize: 16,
        gap: 8,
      ),
    );
  }
}

class InlineLinkText extends StatelessWidget {
  const InlineLinkText({
    required this.prefix,
    required this.action,
    this.onPressed,
    this.centered = true,
    super.key,
  });
  final String prefix;
  final String action;
  final VoidCallback? onPressed;
  final bool centered;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: '$prefix$action',
    excludeSemantics: true,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Align(
          alignment: centered ? Alignment.center : Alignment.centerLeft,
          widthFactor: centered ? null : 1,
          child: Text.rich(
            TextSpan(
              style: AppTypography.bodyMedium,
              children: [
                TextSpan(text: prefix),
                TextSpan(
                  text: action,
                  style: AppTypography.link.copyWith(
                    color: onPressed == null
                        ? AppColors.textDisabled
                        : AppColors.brand,
                  ),
                ),
              ],
            ),
            textAlign: centered ? TextAlign.center : TextAlign.start,
          ),
        ),
      ),
    ),
  );
}

class _ButtonFrame extends StatelessWidget {
  const _ButtonFrame({
    required this.label,
    required this.loading,
    required this.onPressed,
    required this.minHeight,
    required this.padding,
    required this.radius,
    required this.color,
    required this.child,
    this.border,
    this.shadows,
  });
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final double minHeight;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final BoxBorder? border;
  final List<BoxShadow>? shadows;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: loading ? '$label. ${AppStrings.loading}' : label,
      liveRegion: loading,
      excludeSemantics: true,
      child: PressableScale(
        enabled: onPressed != null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: color,
            borderRadius: shape,
            border: border,
            boxShadow: shadows,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              borderRadius: shape,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight, minWidth: 48),
                child: Padding(
                  padding: padding.add(
                    const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Center(widthFactor: 1, child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.loading,
    required this.color,
    required this.style,
    required this.iconSize,
    required this.gap,
    this.leading,
    this.trailing,
  });
  final String label;
  final bool loading;
  final Color color;
  final TextStyle style;
  final double iconSize;
  final double gap;
  final AppIcons? leading;
  final AppIcons? trailing;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (loading) ...[
        SizedBox.square(
          dimension: iconSize,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
        SizedBox(width: gap),
      ] else if (leading != null) ...[
        AppIcon(leading!, size: iconSize, color: color),
        SizedBox(width: gap),
      ],
      Flexible(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: style.copyWith(color: color),
        ),
      ),
      if (trailing != null && !loading) ...[
        SizedBox(width: gap),
        AppIcon(trailing!, size: iconSize, color: color),
      ],
    ],
  );
}
