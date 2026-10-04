import 'package:flutter/material.dart';

import 'motion_tokens.dart';

class PressableScale extends StatefulWidget {
  const PressableScale({required this.child, this.enabled = true, super.key});
  final Widget child;
  final bool enabled;
  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;
  void _setPressed(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  void didUpdateWidget(covariant PressableScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) _pressed = false;
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
    onPointerUp: (_) => _setPressed(false),
    onPointerCancel: (_) => _setPressed(false),
    child: MediaQuery.disableAnimationsOf(context)
        ? AnimatedOpacity(
            duration: MotionTokens.press,
            opacity: _pressed ? 0.8 : 1,
            child: widget.child,
          )
        : AnimatedScale(
            duration: MotionTokens.press,
            curve: MotionTokens.easeOut,
            scale: _pressed ? MotionTokens.pressedScale : 1,
            child: widget.child,
          ),
  );
}
