import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'motion_tokens.dart';

class MotionReveal extends StatefulWidget {
  const MotionReveal({
    required this.child,
    this.index = 0,
    this.delight = false,
    super.key,
  });
  final Widget child;
  final int index;
  final bool delight;
  @override
  State<MotionReveal> createState() => _MotionRevealState();
}

class _MotionRevealState extends State<MotionReveal>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: MotionTokens.entrance,
    upperBound: 1.1,
  );
  Timer? _timer;
  bool _started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _timer = Timer(MotionTokens.stagger * widget.index.clamp(0, 7), () {
      if (!mounted) return;
      if (widget.delight && !MediaQuery.disableAnimationsOf(context)) {
        unawaited(
          _controller.animateWith(SpringSimulation(MotionTokens.pop, 0, 1, 0)),
        );
      } else {
        unawaited(_controller.animateTo(1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      final reduced = MediaQuery.disableAnimationsOf(context);
      final value = widget.delight
          ? _controller.value
          : MotionTokens.easeOut.transform(_controller.value.clamp(0, 1));
      return Opacity(
        opacity: value.clamp(0, 1),
        child: reduced
            ? child
            : Transform.scale(
                scale:
                    MotionTokens.enteringScale +
                    (1 - MotionTokens.enteringScale) * value,
                child: child,
              ),
      );
    },
  );
}
