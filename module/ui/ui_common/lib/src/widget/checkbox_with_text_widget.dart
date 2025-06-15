import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

class CheckboxWithTextWidget extends StatelessWidget {
  const CheckboxWithTextWidget({
    super.key,
    this.text,
    this.tristate = false,
    this.reversed = false,
    this.value,
    required this.onChanged,
  });

  final Widget? text;

  final bool tristate;

  final bool reversed;

  final bool? value;

  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final children = [
      Checkbox(tristate: tristate, value: value, onChanged: onChanged),
      text,
    ].nonNulls.intersperse(const SizedBox(width: 4));
    if (children.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [if (reversed) ...children.toList().reversed else ...children],
    );
  }
}
