import 'package:flutter/material.dart';

class BottomSheetRoute<T> extends Page<T> {
  const BottomSheetRoute({
    required this.child,
    this.isScrollControlled = false,
    this.draggable = true,
    this.cancelable = true,
    this.backgroundColor,
    this.barrierColor,
    this.elevation = 0,
    super.key,
    super.name,
    super.arguments,
  });

  final bool isScrollControlled;

  final bool draggable;

  final bool cancelable;

  final Color? backgroundColor;

  final Color? barrierColor;

  final double elevation;

  final Widget Function(BuildContext, ScrollController?) child;

  @override
  Route<T> createRoute(BuildContext context) {
    final statusBar = MediaQuery.of(context).viewPadding.top;
    final maxHeight = MediaQuery.of(context).size.height - statusBar;

    return ModalBottomSheetRoute(
      settings: this,
      isScrollControlled: isScrollControlled,
      isDismissible: cancelable,
      enableDrag: draggable,
      modalBarrierColor: barrierColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: elevation,
      showDragHandle: true,
      constraints: BoxConstraints(maxHeight: maxHeight),
      builder: (context) => isScrollControlled
          ? DraggableScrollableSheet(
              expand: false,
              builder: (context, controller) => child(context, controller),
            )
          : child(context, null),
    );
  }
}
