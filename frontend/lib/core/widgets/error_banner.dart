import 'package:flutter/material.dart';

import '../errors/app_exception.dart';
import '../l10n/app_strings.dart';
import '../l10n/error_messages.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'app_buttons.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({required this.error, this.onRetry, super.key});
  final AppException error;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerSubtle,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.iconDanger,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ErrorMessages.forException(error),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextLinkButton(
                label: AppStrings.retry,
                onPressed: onRetry,
              ),
            ),
        ],
      ),
    ),
  );
}
