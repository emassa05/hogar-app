import 'dart:async';

import 'package:flutter/material.dart';

import '../motion/app_haptics.dart';
import '../motion/pressable_scale.dart';

class SelectableChip extends StatelessWidget {
  const SelectableChip({
    required this.label,
    required this.selected,
    this.onSelected,
    super.key,
  });
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  @override
  Widget build(BuildContext context) => PressableScale(
    enabled: onSelected != null,
    child: FilterChip(
      label: Text(label),
      selected: selected,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      onSelected: onSelected == null
          ? null
          : (value) {
              unawaited(AppHaptics.selection());
              onSelected!(value);
            },
    ),
  );
}
