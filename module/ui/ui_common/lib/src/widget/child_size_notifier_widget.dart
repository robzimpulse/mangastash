import 'package:flutter/widgets.dart';

class ChildSizeNotifierWidget extends StatefulWidget {
  final Widget? child;

  final Widget Function(
    BuildContext context,
    Size? size,
    Widget? child,
  ) builder;

  const ChildSizeNotifierWidget({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  State<ChildSizeNotifierWidget> createState() =>
      _ChildSizeNotifierWidgetState();
}

class _ChildSizeNotifierWidgetState extends State<ChildSizeNotifierWidget> {
  late final ValueNotifier<Size> notifier = ValueNotifier(Size.zero);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) {
          final renderBox = context.findRenderObject() as RenderBox?;
          notifier.value = renderBox?.size ?? Size.zero;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: widget.builder,
      child: widget.child,
    );
  }
}
