import 'package:flutter/material.dart';

class DecoratedPreferredSizeWidget extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Size get preferredSize => child.preferredSize;

  final PreferredSizeWidget child;

  final Decoration? decoration;

  const DecoratedPreferredSizeWidget({
    super.key,
    required this.child,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      child: child,
    );
  }
}
