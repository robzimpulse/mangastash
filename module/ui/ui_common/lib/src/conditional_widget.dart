import 'package:flutter/widgets.dart';

class ConditionalWidget extends StatelessWidget {
  final bool value;

  final Widget child;

  final Widget otherChild;

  const ConditionalWidget({
    super.key,
    required this.value,
    required this.child,
    required this.otherChild,
  });

  @override
  Widget build(BuildContext context) {
    return value ? child : otherChild;
  }
}
