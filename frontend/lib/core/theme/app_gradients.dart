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
  static const household = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDDE3FD), Color(0xFFF8F9FC), Color(0xFFEFEAF9)],
    stops: [0, 0.3, 1],
  );
  static const violetHalo = RadialGradient(
    colors: [Color(0x99C8B9F5), Color(0x00C8B9F5)],
  );
  static const warmHalo = RadialGradient(
    colors: [Color(0x99FFE4A5), Color(0x00FFE4A5)],
  );
  static const skyHalo = RadialGradient(
    colors: [Color(0x99A9E4ED), Color(0x00A9E4ED)],
  );
}
