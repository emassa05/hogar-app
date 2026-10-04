import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../session/session_user.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    this.avatar,
    this.name = '',
    this.size = 48,
    this.selected = false,
    super.key,
  });
  final AvatarChoice? avatar;
  final String name;
  final double size;
  final bool selected;
  static const colors = {
    AvatarChoice.indigo: Color(0xFFE0E5FD),
    AvatarChoice.green: Color(0xFFD6F7E4),
    AvatarChoice.peach: Color(0xFFFDE3D2),
    AvatarChoice.yellow: Color(0xFFFDEFC9),
    AvatarChoice.sky: Color(0xFFD2F1F7),
    AvatarChoice.pink: Color(0xFFFBDFEC),
  };
  static const names = {
    AvatarChoice.indigo: 'índigo',
    AvatarChoice.green: 'verde',
    AvatarChoice.peach: 'durazno',
    AvatarChoice.yellow: 'amarillo',
    AvatarChoice.sky: 'celeste',
    AvatarChoice.pink: 'rosado',
  };
  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first)
        .join()
        .toUpperCase();
    return Semantics(
      image: true,
      label: avatar == null
          ? AppStrings.initials(name)
          : AppStrings.character(names[avatar]!),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors[avatar] ?? AppColors.brandSubtle,
          border: Border.all(
            color: selected ? AppColors.brand : AppColors.surface,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: avatar == null
              ? Center(
                  child: Text(
                    initials.isEmpty ? '?' : initials,
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: size * 0.32,
                      color: AppColors.brand,
                    ),
                    textScaler: TextScaler.noScaling,
                  ),
                )
              : Transform.scale(
                  scale: 1.17,
                  child: Image.asset(
                    'assets/images/avatars/avatar-${avatar!.name}.png',
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
        ),
      ),
    );
  }
}
