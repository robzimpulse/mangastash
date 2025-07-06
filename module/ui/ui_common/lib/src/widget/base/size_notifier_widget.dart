import 'package:flutter/material.dart';

class SizeNotifierWidget extends StatelessWidget {
  SizeNotifierWidget({
    super.key,
    required this.child,
    required this.size,
  });

  final ValueNotifier<Size> _notifier = ValueNotifier(Size.zero);

  final Widget child;

  final void Function(BuildContext context, Size size) size;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final object = context.findRenderObject();
        if (object is RenderBox) _notifier.value = object.size;
      },
    );

    return ValueListenableBuilder(
      valueListenable: _notifier,
      builder: (context, size, _) {
        this.size.call(context, size);
        return child;
      },
      child: child,
    );
  }
}
