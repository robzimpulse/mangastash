import 'package:flutter/material.dart';

import 'shimmer_area_widget.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;

  final Widget child;

  ShimmerLoading.box({
    Key? key,
    required bool isLoading,
    required double? width,
    required double? height,
    double radius = 16,
    Widget child = const SizedBox(),
  }) : this(
          key: key,
          isLoading: isLoading,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBF4),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );

  ShimmerLoading.circular({
    Key? key,
    required bool isLoading,
    required double? size,
    Widget child = const SizedBox(),
  }) : this(
          key: key,
          isLoading: isLoading,
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        );

  ShimmerLoading.multiline({
    Key? key,
    required bool isLoading,
    required double width,
    required double height,
    required int lines,
    double spacing = 4,
    Widget child = const SizedBox(),
  }) : this(
          key: key,
          isLoading: isLoading,
          child: Column(
            children: List.generate(
              lines,
              (index) => Container(
                margin: index != 0 ? EdgeInsets.only(top: spacing) : null,
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );

  ShimmerLoading.dots({
    Key? key,
    required bool isLoading,
    required double size,
    int count = 3,
    double spacing = 4.0,
    Widget child = const SizedBox(),
  }) : this(
          key: key,
          isLoading: isLoading,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              count,
              (index) => Container(
                width: size,
                height: size,
                margin: EdgeInsets.symmetric(horizontal: spacing / 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shimmerChanges?.removeListener(_onShimmerChange);
    _shimmerChanges = ShimmerAreaWidget.of(context)?.shimmerChanges
      ?..addListener(_onShimmerChange);
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChange);
    super.dispose();
  }

  void _onShimmerChange() {
    if (!widget.isLoading) return;
    // update the shimmer painting.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    // Collect ancestor shimmer information.
    final shimmer = ShimmerAreaWidget.of(context);

    // The ancestor Shimmer widget isn’t laid
    // out yet. Return an empty box.
    if (shimmer == null || shimmer.isSized != true) {
      return const SizedBox();
    }

    final shimmerSize = shimmer.size;
    final gradient = shimmer.gradient;
    late Offset offsetWithinShimmer;
    try {
      if (context.findRenderObject() is RenderBox) {
        // [getDescendantOffset] sometimes causes error "Null check operator used on a null value"
        // when parent widget is disposed before shimmer is rendered.
        offsetWithinShimmer = shimmer.getDescendantOffset(
          descendant: context.findRenderObject() as RenderBox,
        );
      } else {
        offsetWithinShimmer = Offset.zero;
      }
    } catch (e) {
      // set to [Offset.zero] if error is caught
      offsetWithinShimmer = Offset.zero;
    }

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(
            -offsetWithinShimmer.dx,
            -offsetWithinShimmer.dy,
            shimmerSize.width,
            shimmerSize.height,
          ),
        );
      },
      child: widget.child,
    );
  }
}
