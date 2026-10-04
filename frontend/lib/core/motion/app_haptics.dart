import 'package:flutter/services.dart';

abstract final class AppHaptics {
  static Future<void> selection() => HapticFeedback.selectionClick();
  static Future<void> commit() => HapticFeedback.lightImpact();
  static Future<void> success() => HapticFeedback.mediumImpact();
  static Future<void> error() => HapticFeedback.heavyImpact();
}
