import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/validation/validators.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_icon.dart';
import '../household_strings.dart';

class InvitationCodeCard extends StatelessWidget {
  const InvitationCodeCard({
    required this.code,
    required this.onCopy,
    required this.onShare,
    this.onRegenerate,
    this.busy = false,
    super.key,
  });
  final String code;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onRegenerate;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final display = CodeValidator.displayInvitation(code);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Semantics(
            label: HouseholdStrings.codeLabel(display.split('').join(' ')),
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.sunken,
                borderRadius: BorderRadius.circular(14),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  display,
                  style: AppTypography.code.copyWith(
                    fontSize: 22,
                    height: 26 / 22,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.32,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Actions(busy: busy, onCopy: onCopy, onShare: onShare),
          const SizedBox(height: 14),
          Text(
            HouseholdStrings.invitationHelp,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
          if (onRegenerate != null)
            TextLinkButton(
              label: HouseholdStrings.regenerate,
              loading: busy,
              onPressed: onRegenerate,
            ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.busy,
    required this.onCopy,
    required this.onShare,
  });
  final bool busy;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  @override
  Widget build(BuildContext context) {
    final copy = _CodeButton(
      label: HouseholdStrings.copy,
      icon: AppIcons.copy,
      primary: true,
      onPressed: busy ? null : onCopy,
    );
    final share = _CodeButton(
      label: HouseholdStrings.share,
      icon: AppIcons.share,
      primary: false,
      onPressed: busy ? null : onShare,
    );
    if (MediaQuery.textScalerOf(context).scale(10) >= 15) {
      return Column(children: [copy, const SizedBox(height: 10), share]);
    }
    return Row(
      children: [
        Expanded(child: copy),
        const SizedBox(width: 10),
        Expanded(child: share),
      ],
    );
  }
}

class _CodeButton extends StatelessWidget {
  const _CodeButton({
    required this.label,
    required this.icon,
    required this.primary,
    this.onPressed,
  });
  final String label;
  final AppIcons icon;
  final bool primary;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final foreground = primary ? AppColors.inverse : AppColors.textPrimary;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: primary ? AppColors.brand : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: primary
              ? BorderSide.none
              : const BorderSide(color: AppColors.borderStrong),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(icon, size: 18, color: foreground),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: AppTypography.buttonCompact.copyWith(
                        color: foreground,
                      ),
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
}
