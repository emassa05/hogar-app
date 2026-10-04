import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../motion/pressable_scale.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    this.pill = true,
    this.icon,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool pill;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => PressableScale(
    enabled: onPressed != null && !loading,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          pill ? AppRadius.pill : AppRadius.medium,
        ),
        boxShadow: onPressed != null && !loading && pill
            ? AppShadows.primaryAction
            : null,
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                pill ? AppRadius.pill : AppRadius.medium,
              ),
            ),
          ),
          onPressed: loading ? null : onPressed,
          child: _ButtonContent(
            label: label,
            loading: loading,
            icon: icon,
            color: loading ? AppColors.brand : AppColors.inverse,
          ),
        ),
      ),
    ),
  );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    this.icon,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => PressableScale(
    enabled: onPressed != null && !loading,
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        child: _ButtonContent(
          label: label,
          loading: loading,
          icon: icon,
          color: AppColors.brand,
        ),
      ),
    ),
  );
}

class TextLinkButton extends StatelessWidget {
  const TextLinkButton({
    required this.label,
    this.onPressed,
    this.loading = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  @override
  Widget build(BuildContext context) => PressableScale(
    enabled: onPressed != null && !loading,
    child: TextButton(
      onPressed: loading ? null : onPressed,
      child: _ButtonContent(
        label: label,
        loading: loading,
        color: AppColors.brand,
      ),
    ),
  );
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.loading,
    required this.color,
    this.icon,
  });
  final String label;
  final bool loading;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: loading,
    label: loading ? AppStrings.loading : null,
    child: Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        if (loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
        Text(label, textAlign: TextAlign.center),
        if (icon != null && !loading) Icon(icon, size: 20),
      ],
    ),
  );
}
