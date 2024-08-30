import 'package:flutter/material.dart';

import 'widget/shimmer_area_widget.dart';

class ScaffoldScreen extends StatelessWidget {
  final Widget body;

  final Widget? bottomNavigationBar;

  final bool canPop;

  final PopInvokedCallback? onPopInvoked;

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
    return PopScope(
      canPop: canPop,
      onPopInvoked: onPopInvoked,
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
    );
  }
}
