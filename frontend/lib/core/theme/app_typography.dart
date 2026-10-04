import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const sans = 'Plus Jakarta Sans';
  static const mono = 'JetBrains Mono';
  static const serif = 'Instrument Serif';

  static const titleLarge = TextStyle(
    fontFamily: sans,
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );
  static const titleMedium = TextStyle(
    fontFamily: sans,
    fontSize: 17,
    height: 20 / 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.085,
    color: AppColors.textPrimary,
  );
  static const titleSmall = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    height: 18 / 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const cardTitle = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const labelLarge = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const labelMedium = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.12,
    color: AppColors.textSecondary,
  );
  static const labelSmall = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.06,
    color: AppColors.textPrimary,
  );
  static const fieldLabel = TextStyle(
    fontFamily: sans,
    fontSize: 13,
    height: 16 / 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static const fieldInput = TextStyle(
    fontFamily: sans,
    fontSize: 17,
    height: 22 / 17,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.17,
    color: AppColors.textPrimary,
  );
  static const fieldInputCompact = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static const obscuredInput = TextStyle(
    fontFamily: sans,
    fontSize: 18,
    height: 22 / 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.16,
    color: AppColors.textPrimary,
  );
  static const bodyMedium = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static const bodyMediumStrong = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const bodySmall = TextStyle(
    fontFamily: sans,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static const caption = TextStyle(
    fontFamily: sans,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );
  static const dataSmall = TextStyle(
    fontFamily: mono,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );
  static const dataMedium = TextStyle(
    fontFamily: mono,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
  );
  static const dataBody = TextStyle(
    fontFamily: mono,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const overline = TextStyle(
    fontFamily: mono,
    fontSize: 10.5,
    height: 14 / 10.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.63,
    color: AppColors.textTertiary,
  );
  static const code = TextStyle(
    fontFamily: mono,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
    color: AppColors.brand,
  );
  static const display = TextStyle(
    fontFamily: sans,
    fontSize: 26,
    height: 32 / 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.26,
    color: AppColors.textPrimary,
  );
  static const displayName = TextStyle(
    fontFamily: sans,
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const metric = TextStyle(
    fontFamily: sans,
    fontSize: 18,
    height: 22 / 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.18,
    color: AppColors.textPrimary,
  );
  static const hero = TextStyle(
    fontFamily: sans,
    fontSize: 30,
    height: 36 / 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );
  static const accent = TextStyle(
    fontFamily: serif,
    fontSize: 37,
    height: 36 / 37,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    color: AppColors.brand,
  );
  static const introduction = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static const button = TextStyle(
    fontFamily: sans,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
  );
  static const buttonCompact = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    height: 16 / 14,
    fontWeight: FontWeight.w600,
  );
  static const textAction = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const link = TextStyle(
    fontFamily: sans,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    color: AppColors.brand,
  );

  static const textTheme = TextTheme(
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
    bodyLarge: introduction,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    displaySmall: hero,
    headlineSmall: display,
  );
}
