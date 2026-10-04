import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

enum AccentTitleSize { regular, celebration, hero }

class AccentTitle extends StatelessWidget {
  const AccentTitle({
    required this.text,
    required this.accent,
    this.suffix = '',
    this.centered = false,
    this.size = AccentTitleSize.regular,
    super.key,
  });
  final String text;
  final String accent;
  final String suffix;
  final bool centered;
  final AccentTitleSize size;

  (TextStyle, TextStyle) get _styles => switch (size) {
    AccentTitleSize.regular => (AppTypography.hero, AppTypography.accent),
    AccentTitleSize.celebration => (
      AppTypography.hero.copyWith(
        fontSize: 38,
        height: 42 / 38,
        letterSpacing: -0.76,
      ),
      AppTypography.accent.copyWith(fontSize: 45, height: 42 / 45),
    ),
    AccentTitleSize.hero => (
      AppTypography.hero.copyWith(
        fontSize: 50,
        height: 52 / 50,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      ),
      AppTypography.accent.copyWith(
        fontSize: 62,
        height: 52 / 62,
        letterSpacing: -0.62,
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (base, highlight) = _styles;
    return Semantics(
      header: true,
      child: Text.rich(
        TextSpan(
          style: base,
          children: [
            TextSpan(text: text),
            TextSpan(text: accent, style: highlight),
            TextSpan(text: suffix),
          ],
        ),
        textAlign: centered ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}
