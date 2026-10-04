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
    this.borderWidth = 0,
    this.borderColor = AppColors.surface,
    this.shadows,
    this.background,
    this.foreground = AppColors.categoryFourText,
    this.semanticLabel,
    super.key,
  });
  final AvatarChoice? avatar;
  final String name;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final List<BoxShadow>? shadows;
  final Color? background;
  final Color foreground;
  final String? semanticLabel;

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

  static String initialsOf(String name) => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part.characters.first)
      .join()
      .toUpperCase();

  Rect _imageRect(double inner) {
    if (size >= 120) return Rect.fromLTWH(0, inner * 12 / 172, inner, inner);
    if (borderWidth > 0) {
      return Rect.fromLTWH(
        -inner * 9 / 66,
        inner * 3 / 66,
        inner * 84 / 66,
        inner * 84 / 66,
      );
    }
    return Rect.fromLTWH(-inner * 0.1, inner * 0.1, inner * 1.2, inner * 1.2);
  }

  @override
  Widget build(BuildContext context) {
    final inner = size - borderWidth * 2;
    final initials = initialsOf(name);
    final image = _imageRect(inner);
    return Semantics(
      image: true,
      label:
          semanticLabel ??
          (avatar == null
              ? AppStrings.initials(name)
              : AppStrings.character(names[avatar]!)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: background ?? colors[avatar] ?? colors[AvatarChoice.peach],
          border: borderWidth == 0
              ? null
              : Border.all(color: borderColor, width: borderWidth),
          boxShadow: shadows,
        ),
        child: ClipOval(
          child: avatar == null
              ? Center(
                  child: Text(
                    initials.isEmpty ? '?' : initials,
                    textScaler: TextScaler.noScaling,
                    style: AppTypography.display.copyWith(
                      fontSize: size * 0.45,
                      height: 1,
                      letterSpacing: 0,
                      color: foreground,
                    ),
                  ),
                )
              : Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fromRect(
                      rect: image,
                      child: Image.asset(
                        'assets/images/avatars/avatar-${avatar!.name}.png',
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
