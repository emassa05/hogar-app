import 'package:flutter/material.dart';

import '../errors/app_exception.dart';
import '../l10n/app_strings.dart';
import '../l10n/error_messages.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_buttons.dart';
import 'app_icon.dart';
import 'info_banner.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    required this.error,
    this.onRetry,
    this.message,
    super.key,
  });
  final AppException error;
  final VoidCallback? onRetry;
  final String? message;
  @override
  Widget build(BuildContext context) => InfoBanner(
    tone: BannerTone.danger,
    icon: AppIcons.alertCircle,
    message: message ?? ErrorMessages.forException(error),
    action: onRetry == null
        ? null
        : Align(
            alignment: Alignment.centerLeft,
            child: TextLinkButton(
              label: AppStrings.retry,
              onPressed: onRetry,
              style: AppTypography.link.copyWith(color: AppColors.danger),
              underline: true,
            ),
          ),
  );
}
