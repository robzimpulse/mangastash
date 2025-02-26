import 'package:flutter/material.dart';

class BottomSheetRouteV2<T> extends Page<T> {
  const BottomSheetRouteV2({
    required this.child,
    this.isScrollControlled = false,
    this.draggable = true,
    this.cancelable = true,
    this.backgroundColor,
    this.modalBarrierColor,
    this.elevation = 0,
    super.key,
    super.name,
    super.arguments,
  });

  final bool isScrollControlled;

  final bool draggable;

  final bool cancelable;

  final Color? backgroundColor;

  final Color? modalBarrierColor;

  final double elevation;

  // final Widget child;

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
      modalBarrierColor: modalBarrierColor,
      elevation: elevation,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (draggable)
            Container(
              alignment: Alignment.center,
              height: 16,
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey,
                ),
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: child.call(
              context,
              null,
            ),
          ),
        ],
      ),
    );
  }
}
