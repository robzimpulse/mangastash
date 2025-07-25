import 'dart:ui';

import 'package:ui_common/ui_common.dart';

class MangaDetailAppBarWidget extends StatelessWidget {
  const MangaDetailAppBarWidget({
    super.key,
    required this.progress,
    this.background,
    this.actions,
    this.leading,
    this.title,
    this.actionsDecoration,
  });

  final double progress;

  final Widget? background;

  final List<Widget>? actions;

  final Widget? leading;

  final Widget? title;

  final BoxDecoration? actionsDecoration;

  @override
  Widget build(BuildContext context) {
    final background = this.background;
    final actions = this.actions;
    final leading = this.leading;
    final title = this.title;

    return Stack(
      children: [
        if (background != null)
          Positioned.fill(
            child: background,
          ),
        if (leading != null)
          Positioned(
            left: 0,
            top: 4,
            child: SafeArea(child: leading),
          ),
        if (actions != null)
          Positioned(
            right: 0,
            top: 4,
            child: SafeArea(
              child: Container(
                decoration: actionsDecoration,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions,
                ),
              ),
            ),
          ),
        if (title != null)
          Positioned(
            left: lerpDouble(0, 48, progress),
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