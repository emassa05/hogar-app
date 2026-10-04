import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AuthIllustration extends StatelessWidget {
  const AuthIllustration({
    required this.asset,
    this.color = AppColors.brand,
    this.height = 232,
    super.key,
  });
  final String asset;
  final Color color;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Center(
      child: SizedBox.square(
        dimension: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.12),
                    color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            CustomPaint(painter: _OrbitPainter(color.withValues(alpha: 0.22))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/$asset',
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
            Positioned(
              top: 30,
              right: 14,
              child: Icon(
                Icons.auto_awesome,
                size: 14,
                color: color.withValues(alpha: 0.55),
              ),
            ),
            Positioned(
              bottom: 42,
              left: 8,
              child: Icon(
                Icons.auto_awesome,
                size: 11,
                color: const Color(0xFFE9B645),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final bounds = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width - 6,
      height: size.height - 6,
    );
    for (var angle = 0.0; angle < pi * 2; angle += 0.12) {
      canvas.drawArc(bounds, angle, 0.025, false, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) => oldDelegate.color != color;
}
