import 'package:flutter/material.dart';

class ScaffoldScreen extends StatelessWidget {
  final Widget body;

  final Widget? bottomNavigationBar;

  final WillPopCallback? onWillPop;

  final PreferredSizeWidget? appBar;

  final Color? backgroundColor;

  final bool bottomSafeArea;

  const ScaffoldScreen({
    super.key,
    this.onWillPop,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.bottomSafeArea = true,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
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
    );
  }
}
