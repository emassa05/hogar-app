import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const elevationSmall = [
    BoxShadow(offset: Offset(0, 2), blurRadius: 5, color: Color(0x0D2A2419)),
    BoxShadow(offset: Offset(0, 1), blurRadius: 1, color: Color(0x0A2A2419)),
  ];
  static const elevationMedium = [
    BoxShadow(offset: Offset(0, 8), blurRadius: 16, color: Color(0x122A2419)),
    BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Color(0x0A2A2419)),
  ];
  static const bottomBar = [
    BoxShadow(offset: Offset(0, -6), blurRadius: 18, color: Color(0x0F2A2419)),
  ];
  static const primaryAction = [
    BoxShadow(offset: Offset(0, 10), blurRadius: 24, color: Color(0x474338CA)),
    BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Color(0x2E4338CA)),
  ];
  static const field = [
    BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0A1E1A5E)),
  ];
  static const focusRing = [
    BoxShadow(spreadRadius: 4, color: Color(0x245B4FE0)),
  ];
  static const dangerRing = [
    BoxShadow(spreadRadius: 4, color: Color(0x1FDC4747)),
  ];
  static const floating = [
    BoxShadow(offset: Offset(0, 10), blurRadius: 24, color: Color(0x1A1E1A5E)),
    BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Color(0x0D1E1A5E)),
  ];
  static const outlinedPill = [
    BoxShadow(offset: Offset(0, 2), blurRadius: 6, color: Color(0x0D1E1A5E)),
  ];
  static const card = [
    BoxShadow(offset: Offset(0, 6), blurRadius: 18, color: Color(0x0F1E1A5E)),
  ];
  static const avatarOption = [
    BoxShadow(offset: Offset(0, 4), blurRadius: 10, color: Color(0x141E1A5E)),
  ];
  static const avatarHero = [
    BoxShadow(offset: Offset(0, 12), blurRadius: 30, color: Color(0x2E0B6E83)),
  ];
  static const badge = [
    BoxShadow(offset: Offset(0, 6), blurRadius: 14, color: Color(0x2E1E1A5E)),
  ];
}
