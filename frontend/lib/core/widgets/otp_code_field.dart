import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_strings.dart';
import '../motion/app_haptics.dart';
import '../motion/motion_tokens.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    required this.onChanged,
    this.errorPulse = 0,
    this.enabled = true,
    super.key,
  });
  final ValueChanged<String> onChanged;
  final int errorPulse;
  final bool enabled;
  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  late final _shake = AnimationController(
    vsync: this,
    duration: MotionTokens.shake,
  );
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
    if (oldWidget.errorPulse != widget.errorPulse) {
      unawaited(AppHaptics.error());
      unawaited(_shake.forward(from: 0));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
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
      height: 64,
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: Row(
                children: List.generate(
                  6,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index == 5 ? 0 : 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color:
                              _focus.hasFocus &&
                                  index == _controller.text.length.clamp(0, 5)
                              ? AppColors.focus
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        index < _controller.text.length
                            ? _controller.text[index]
                            : '',
                        style: AppTypography.code.copyWith(fontSize: 24),
                        textScaler: TextScaler.noScaling,
                      ),
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
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: widget.onChanged,
                showCursor: false,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
