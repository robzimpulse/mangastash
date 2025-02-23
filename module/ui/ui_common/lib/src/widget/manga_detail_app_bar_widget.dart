import 'dart:ui';

import 'package:flutter/material.dart';

class MangaDetailAppBarWidget extends StatelessWidget {
  const MangaDetailAppBarWidget({
    super.key,
    required this.progress,
    this.background,
    this.actions,
    this.leading,
    this.title,
  });

  final double progress;

  final Widget? background;

  final List<Widget>? actions;

  final Widget? leading;

  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final background = this.background;
    final actions = this.actions;
    final leading = this.leading;
    final title = this.title;

    // TODO: fix `actions` animation

    return Stack(
      children: [
        if (background != null)
          Positioned.fill(
            child: background,
          ),
        if (leading != null)
          Positioned(
            left: 4,
            top: 28,
            child: leading,
          ),
        if (actions != null)
          Positioned(
            right: 0,
            top: 28,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
          ),
        if (title != null)
          Positioned(
            left: lerpDouble(0, 56, progress),
            right: lerpDouble(0, 48 * (actions?.length ?? 0.0), progress),
            top: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: lerpDouble(16, 0, progress) ?? 0,
                ),
                alignment: Alignment.lerp(
                  Alignment.center,
                  Alignment.centerLeft,
                  progress,
                ),
                child: title,
              ),
            ),
          ),
      ],
    );
  }
}
