import 'package:flutter/material.dart';

class ScaffoldScreen extends StatelessWidget {
  final Widget body;

  final Widget? bottomNavigationBar;

  final WillPopCallback? onWillPop;

  final PreferredSizeWidget? appBar;

  final Color? backgroundColor;

  const ScaffoldScreen({
    super.key,
    this.onWillPop,
    this.appBar,
    this.bottomNavigationBar,
    this.backgroundColor,
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
        body: body,
      ),
    );
  }
}
