import 'package:flutter/material.dart';

class ScaffoldScreen extends StatelessWidget {
  final Widget child;

  final WillPopCallback? onWillPop;

  final PreferredSizeWidget? appBar;

  const ScaffoldScreen({
    super.key,
    this.onWillPop,
    required this.child,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: appBar,
        body: child,
      ),
    );
  }
}
