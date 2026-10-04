import 'dart:math';

import 'package:flutter/material.dart';

abstract final class AppGradients {
  static const canvas = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFEFEBFE),
      Color(0xFFF3F4FE),
      Color(0xFFF7F8FB),
      Color(0xFFFFFFFF),
    ],
    stops: [0, 0.3, 0.6, 1],
  );
  static const celebration = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE9E2FD),
      Color(0xFFEEF1FE),
      Color(0xFFF7F8FB),
      Color(0xFFFFFFFF),
    ],
    stops: [0, 0.36, 0.62, 1],
  );
  static const household = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    transform: GradientRotation(-pi / 36),
    colors: [Color(0xFFFFFFFF), Color(0xFFF6F7FC), Color(0xFFEEECFA)],
    stops: [0.11, 0.44, 0.9],
  );
  static const avatarPreview = RadialGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFD2F1F7)],
  );
}
