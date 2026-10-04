import 'dart:ui';

import 'package:flutter/material.dart';

class Halo {
  const Halo({
    required this.top,
    required this.width,
    required this.height,
    required this.color,
    this.left,
    this.right,
    this.blur = 45,
  });
  final double top;
  final double? left;
  final double? right;
  final double width;
  final double height;
  final Color color;
  final double blur;
}

abstract final class AppHalos {
  static const violet = Color(0xFFD6C7FA);
  static const mint = Color(0xFFC3F0D8);
  static const butter = Color(0xFFFCE7B0);
  static const peach = Color(0xFFFCD3BD);
  static const sky = Color(0xFFBCE6F4);
  static const rose = Color(0xFFFCCFD2);

  static List<Halo> access(Color accent) => [
    const Halo(left: -140, top: -90, width: 320, height: 280, color: violet),
    Halo(right: -100, top: -60, width: 320, height: 300, color: accent),
  ];

  static const welcome = [
    Halo(
      left: -130,
      top: -70,
      width: 350,
      height: 310,
      color: Color(0xFFC9B6FA),
    ),
    Halo(right: -100, top: -30, width: 300, height: 270, color: sky),
    Halo(
      right: -80,
      top: 250,
      width: 320,
      height: 230,
      color: Color(0xE6C3F0D8),
      blur: 50,
    ),
    Halo(
      left: -120,
      top: 270,
      width: 270,
      height: 210,
      color: Color(0xBFFCD3BD),
      blur: 50,
    ),
  ];

  static const celebration = [
    Halo(left: -140, top: -90, width: 320, height: 280, color: violet),
    Halo(right: -100, top: -60, width: 320, height: 300, color: sky),
    Halo(
      right: -80,
      top: 230,
      width: 320,
      height: 230,
      color: Color(0xE6C3F0D8),
      blur: 50,
    ),
    Halo(
      left: -120,
      top: 250,
      width: 270,
      height: 210,
      color: Color(0xBFFCD3BD),
      blur: 50,
    ),
  ];

  static const household = [
    Halo(
      left: -90,
      top: -110,
      width: 300,
      height: 232,
      color: Color(0x8CC4CCFA),
      blur: 35,
    ),
    Halo(
      right: -100,
      top: -60,
      width: 260,
      height: 182,
      color: Color(0x73D6C7FA),
      blur: 35,
    ),
  ];
}

class HaloLayer extends StatelessWidget {
  const HaloLayer({required this.halos, super.key});
  final List<Halo> halos;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final halo in halos)
            Positioned(
              top: halo.top,
              left: halo.left,
              right: halo.right,
              width: halo.width,
              height: halo.height,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: halo.blur,
                  sigmaY: halo.blur,
                  tileMode: TileMode.decal,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: halo.color,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(halo.width / 2, halo.height / 2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
