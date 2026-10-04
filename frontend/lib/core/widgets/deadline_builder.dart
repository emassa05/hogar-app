import 'dart:async';

import 'package:flutter/material.dart';

class DeadlineBuilder extends StatefulWidget {
  const DeadlineBuilder({required this.builder, this.deadline, super.key});
  final DateTime? deadline;
  final Widget Function(BuildContext context, int seconds) builder;
  @override
  State<DeadlineBuilder> createState() => _DeadlineBuilderState();
}

class _DeadlineBuilderState extends State<DeadlineBuilder> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _seconds > 0) setState(() {});
    });
  }

  int get _seconds => widget.deadline == null
      ? 0
      : (widget.deadline!.difference(DateTime.now().toUtc()).inMilliseconds /
                1000)
            .ceil()
            .clamp(0, 86400);
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _seconds);
}
