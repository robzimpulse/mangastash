import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  PreferredSize preferredSize({
    required BuildContext context,
    required Size size,
  }) {
    return PreferredSize(
      preferredSize: size,
      child: Container(
        width: size.width,
        height: size.height,
        color: Theme.of(context).appBarTheme.backgroundColor,
        padding: const EdgeInsets.all(8),
        child: this,
      ),
    );
  }
}
