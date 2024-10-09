import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BottomSheetRoute<T> extends Page<T> {
  const BottomSheetRoute({
    required this.child,
    this.draggable = true,
    this.cancelable = true,
    this.expanded = false,
    this.modalBarrierColor,
    this.elevation = 0,
    this.backgroundColor,
    this.duration,
    super.key,
    super.name,
    super.arguments,
  });

  final Widget child;

  final bool draggable;

  final bool cancelable;

  final bool expanded;

  final Color? modalBarrierColor;

  final double elevation;

  final Color? backgroundColor;

  final Duration? duration;

  @override
  Route<T> createRoute(BuildContext context) {
    final statusBar = MediaQuery.of(context).viewPadding.top;
    final maxHeight = MediaQuery.of(context).size.height - statusBar;
    return ModalSheetRoute(
      expanded: expanded,
      isDismissible: cancelable,
      enableDrag: draggable,
      modalBarrierColor: modalBarrierColor,
      settings: this,
      duration: duration,
      builder: (context) => SafeArea(
        child: Material(
          elevation: elevation,
          color: backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Wrap(
            children: [
              if (draggable) ...[
                // sheet draggable indicator
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
              ],
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
