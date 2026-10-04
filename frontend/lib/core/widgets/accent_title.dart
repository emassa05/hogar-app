import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

class AccentTitle extends StatelessWidget {
  const AccentTitle({
    required this.text,
    required this.accent,
    this.suffix = '',
    this.centered = false,
    super.key,
  });
  final String text;
  final String accent;
  final String suffix;
  final bool centered;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text.rich(
      TextSpan(
        style: AppTypography.hero,
        children: [
          TextSpan(text: text),
          TextSpan(text: accent, style: AppTypography.accent),
          TextSpan(text: suffix),
        ],
      ),
      textAlign: centered ? TextAlign.center : TextAlign.start,
    ),
  );
}
