import 'package:flutter/material.dart';

class ShimmerAreaWidget extends StatefulWidget {
  const ShimmerAreaWidget({
    super.key,
    this.linearGradient = const LinearGradient(
      colors: [
        Color(0xFFEBEBF4),
        Color(0xFFD0D0D0),
        Color(0xFFEBEBF4),
      ],
      stops: [
        0.1,
        0.8,
        0.9,
      ],
      begin: Alignment(-1.0, -0.3),
      end: Alignment(1.0, 0.3),
      tileMode: TileMode.clamp,
    ),
    this.child,
  });

  final LinearGradient linearGradient;

  final Widget? child;

  @override
  State<ShimmerAreaWidget> createState() => ShimmerAreaWidgetState();

  static ShimmerAreaWidgetState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerAreaWidgetState>();
  }
}

class ShimmerAreaWidgetState extends State<ShimmerAreaWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Gradient get gradient {
    return LinearGradient(
      colors: widget.linearGradient.colors,
      stops: widget.linearGradient.stops,
      begin: widget.linearGradient.begin,
      end: widget.linearGradient.end,
      transform: _SlidingGradientTransform(
        slidePercent: _shimmerController.value,
      ),
    );
  }

  bool get isSized {
    return (context.findRenderObject() as RenderBox?)?.hasSize ?? false;
  }

  Size get size => (context.findRenderObject() as RenderBox).size;

  Listenable get shimmerChanges => _shimmerController;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox();
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
