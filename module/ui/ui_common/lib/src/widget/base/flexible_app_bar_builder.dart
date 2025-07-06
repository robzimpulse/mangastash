import 'dart:ui';

import 'package:flutter/material.dart';

class FlexibleAppBarBuilder extends StatelessWidget {

  final Widget Function(BuildContext, double progress) builder;

  const FlexibleAppBarBuilder({super.key, required this.builder});

  FlexibleSpaceBarSettings? _flexibleSpaceBarSettings(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType();

  double _progress(BuildContext context) {
    final settings = _flexibleSpaceBarSettings(context);
    if (settings == null) return 0;
    final double delta = settings.maxExtent - settings.minExtent;
    final value = 1.0 - (settings.currentExtent - settings.minExtent) / delta;
    return clampDouble(value, 0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: constraints,
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: builder.call(context, _progress(context)),
        ),
      ),
    );
  }

}