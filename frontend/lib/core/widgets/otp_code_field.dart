import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_strings.dart';
import '../motion/app_haptics.dart';
import '../motion/motion_tokens.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

enum OtpStatus { idle, error, success }

class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    required this.onChanged,
    this.controller,
    this.errorPulse = 0,
    this.status = OtpStatus.idle,
    this.enabled = true,
    this.autofocus = true,
    super.key,
  });
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final int errorPulse;
  final OtpStatus status;
  final bool enabled;
  final bool autofocus;
  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField>
    with SingleTickerProviderStateMixin {
  static const length = 6;
  TextEditingController? _ownController;
  final _focus = FocusNode();
  late final _shake = AnimationController(
    vsync: this,
    duration: MotionTokens.shake,
  );

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _focus.addListener(_update);
    _controller.addListener(_update);
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant OtpCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_update);
      _controller.addListener(_update);
    }
    if (oldWidget.errorPulse != widget.errorPulse) {
      unawaited(AppHaptics.error());
      unawaited(_shake.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
    _ownController?.dispose();
    _focus.dispose();
    _shake.dispose();
    super.dispose();
  }

  BoxDecoration _cell(int index) {
    final text = _controller.text;
    final radius = BorderRadius.circular(14);
    switch (widget.status) {
      case OtpStatus.error:
        return BoxDecoration(
          color: AppColors.dangerSubtle,
          borderRadius: radius,
          border: Border.all(color: AppColors.borderDanger, width: 1.5),
        );
      case OtpStatus.success:
        return BoxDecoration(
          color: AppColors.successSubtle,
          borderRadius: radius,
          border: Border.all(color: AppColors.borderSuccess, width: 1.5),
        );
      case OtpStatus.idle:
        final active = _focus.hasFocus && index == min(text.length, length - 1);
        if (active) {
          return BoxDecoration(
            color: AppColors.surface,
            borderRadius: radius,
            border: Border.all(color: AppColors.focus, width: 1.5),
            boxShadow: AppShadows.focusRing,
          );
        }
        return BoxDecoration(
          color: widget.enabled ? AppColors.surface : AppColors.sunken,
          borderRadius: radius,
          border: Border.all(
            color: index < text.length
                ? AppColors.border
                : AppColors.borderSubtle,
          ),
          boxShadow: AppShadows.field,
        );
    }
  }

  Color get _digitColor => switch (widget.status) {
    OtpStatus.error => AppColors.danger,
    OtpStatus.success => AppColors.success,
    OtpStatus.idle =>
      widget.enabled ? AppColors.textPrimary : AppColors.textDisabled,
  };

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.5);
    final text = _controller.text;
    final showCursor =
        widget.status == OtpStatus.idle &&
        _focus.hasFocus &&
        text.length < length;
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          MediaQuery.disableAnimationsOf(context)
              ? 0
              : sin(_shake.value * pi * 6) * 6 * (1 - _shake.value),
          0,
        ),
        child: child,
      ),
      child: SizedBox(
        height: scaler.scale(60),
        child: Stack(
          children: [
            Positioned.fill(
              child: ExcludeSemantics(
                child: Row(
                  children: List.generate(
                    length,
                    (index) => Expanded(
                      child: AnimatedContainer(
                        duration: MotionTokens.press,
                        margin: EdgeInsets.only(
                          right: index == length - 1 ? 0 : 10,
                        ),
                        alignment: Alignment.center,
                        decoration: _cell(index),
                        child: index < text.length
                            ? Text(
                                text[index],
                                textScaler: scaler,
                                style: AppTypography.display.copyWith(
                                  height: 1,
                                  color: _digitColor,
                                ),
                              )
                            : showCursor && index == text.length
                            ? Container(
                                width: 2,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppColors.brand,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Semantics(
                label: AppStrings.otp,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(length),
                  ],
                  onChanged: widget.onChanged,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  style: const TextStyle(color: Colors.transparent),
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
