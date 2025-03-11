import 'package:flutter/material.dart';

class PopupDialogRoute<T> extends Page<T> {
  const PopupDialogRoute({
    this.cancelable = true,
    this.barrierColor,
    required this.child,
    this.anchorPoint,
    this.traversalEdgeBehavior = TraversalEdgeBehavior.closedLoop,
    this.barrierLabel,
    super.key,
    super.name,
    super.arguments,
  });

  final Color? barrierColor;

  final String? barrierLabel;

  final Offset? anchorPoint;

  final TraversalEdgeBehavior traversalEdgeBehavior;

  final bool cancelable;

  final Widget Function(BuildContext) child;

  @override
  Route<T> createRoute(BuildContext context) {
    final statusBar = MediaQuery.of(context).viewPadding.top;
    final maxHeight = MediaQuery.of(context).size.height - statusBar;

    return DialogRoute(
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: child(context),
      ),
      settings: this,
      barrierColor: barrierColor,
      barrierDismissible: cancelable,
      barrierLabel: barrierLabel,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
    );
  }
}
