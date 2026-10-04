import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const elevationMedium = [
    BoxShadow(offset: Offset(0, 8), blurRadius: 16, color: Color(0x122A2419)),
    BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Color(0x0A2A2419)),
  ];
  static const bottomBar = [
    BoxShadow(offset: Offset(0, -6), blurRadius: 18, color: Color(0x0F2A2419)),
  ];
  static const primaryAction = [
    BoxShadow(offset: Offset(0, 10), blurRadius: 24, color: Color(0x334338CA)),
    BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Color(0x1A4338CA)),
  ];
}
