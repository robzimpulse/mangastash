import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widget/shimmer_area_widget.dart';

class ScaffoldScreen extends StatelessWidget {
  final Widget body;

  final Widget? bottomNavigationBar;

  final bool canPop;

  final ValueSetter<bool>? onPopInvoked;

  final PreferredSizeWidget? appBar;

  final Color? backgroundColor;

  final bool bottomSafeArea;

  const ScaffoldScreen({
    super.key,
    this.canPop = true,
    this.onPopInvoked,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.bottomSafeArea = true,
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
