import 'package:flutter/animation.dart';

abstract final class MotionTokens {
  static const press = Duration(milliseconds: 120);
  static const entrance = Duration(milliseconds: 240);
  static const exit = Duration(milliseconds: 168);
  static const shake = Duration(milliseconds: 250);
  static const stagger = Duration(milliseconds: 40);
  static const easeOut = Cubic(0.23, 1, 0.32, 1);
  static const pressedScale = 0.97;
  static const enteringScale = 0.95;
  static const settle = SpringDescription(mass: 1, stiffness: 400, damping: 40);
  static const pop = SpringDescription(mass: 1, stiffness: 400, damping: 32);
}
