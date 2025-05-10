import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

class IconWithTextWidget extends StatelessWidget {
  const IconWithTextWidget({
    super.key,
    this.icon,
    this.text,
  });

  final Widget? icon;
  final Widget? text;

  @override
  Widget build(BuildContext context) {
    final children = [icon, text].nonNulls;
    if (children.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [...children.intersperse(const SizedBox(width: 4))],
    );
  }
}
