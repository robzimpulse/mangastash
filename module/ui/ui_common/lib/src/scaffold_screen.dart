import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widget/base/shimmer_area_widget.dart';

class ScaffoldScreen extends StatelessWidget {
  final Widget body;

  final Widget? bottomNavigationBar;

  final bool canPop;

  final ValueSetter<bool>? onPopInvoked;

  final PreferredSizeWidget? appBar;

  final Color? backgroundColor;

  final bool bottomSafeArea;

  final Widget? floatingActionButton;

  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final FloatingActionButtonAnimator? floatingActionButtonAnimator;

  const ScaffoldScreen({
    super.key,
    this.canPop = true,
    this.onPopInvoked,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.bottomSafeArea = true,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor:
            backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      ),
      child: PopScope(
        canPop: canPop,
        onPopInvokedWithResult: (success, _) => onPopInvoked?.call(success),
        child: ShimmerAreaWidget(
          child: Scaffold(
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
            floatingActionButtonAnimator: floatingActionButtonAnimator,
            backgroundColor: backgroundColor,
            appBar: appBar,
            bottomNavigationBar: bottomNavigationBar,
            body: SafeArea(
              top: false,
              bottom: bottomSafeArea,
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
