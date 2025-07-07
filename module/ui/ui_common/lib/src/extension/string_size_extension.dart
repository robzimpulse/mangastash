import 'package:flutter/material.dart';

extension StringSizeExtension on String {
  Size size({
    TextStyle? style,
    int? maxLines,
    TextScaler textScaler = TextScaler.noScaling,
    TextDirection? textDirection,
    double minWidth = 0.0,
    double maxWidth = double.infinity,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: this, style: style),
      maxLines: maxLines,
      textScaler: textScaler,
      textDirection: textDirection,
    );

    painter.layout(minWidth: minWidth, maxWidth: maxWidth);

    return painter.size;
  }
}
