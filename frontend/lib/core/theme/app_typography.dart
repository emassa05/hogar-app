import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const sans = 'Plus Jakarta Sans';
  static const mono = 'JetBrains Mono';
  static const serif = 'Instrument Serif';

  static const titleLarge = TextStyle(fontFamily: sans, fontSize: 20, height: 24 / 20, fontWeight: FontWeight.w600, letterSpacing: -0.5, color: AppColors.textPrimary);
  static const titleMedium = TextStyle(fontFamily: sans, fontSize: 17, height: 20 / 17, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: AppColors.textPrimary);
  static const labelLarge = TextStyle(fontFamily: sans, fontSize: 14, height: 16 / 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const labelMedium = TextStyle(fontFamily: sans, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, letterSpacing: 1, color: AppColors.textPrimary);
  static const labelSmall = TextStyle(fontFamily: sans, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: AppColors.textPrimary);
  static const bodyMedium = TextStyle(fontFamily: sans, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
  static const bodySmall = TextStyle(fontFamily: sans, fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const caption = TextStyle(fontFamily: sans, fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w400, color: AppColors.textTertiary);
  static const dataSmall = TextStyle(fontFamily: mono, fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w500, color: AppColors.textTertiary);
  static const code = TextStyle(fontFamily: mono, fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, letterSpacing: 2, color: AppColors.brand);
  static const hero = TextStyle(fontFamily: sans, fontSize: 30, height: 36 / 30, fontWeight: FontWeight.w800, letterSpacing: -0.6, color: AppColors.textPrimary);
  static const accent = TextStyle(fontFamily: serif, fontSize: 37, height: 1.1, fontStyle: FontStyle.italic, color: AppColors.brand);
  static const introduction = TextStyle(fontFamily: sans, fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static const button = TextStyle(fontFamily: sans, fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w600);

  static const textTheme = TextTheme(titleLarge: titleLarge, titleMedium: titleMedium, labelLarge: labelLarge, labelMedium: labelMedium, labelSmall: labelSmall, bodyLarge: introduction, bodyMedium: bodyMedium, bodySmall: bodySmall, displaySmall: hero);
}
