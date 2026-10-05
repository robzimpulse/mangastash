import 'package:flutter/widgets.dart';

class NextPageNotificationWidget extends StatelessWidget {
  const NextPageNotificationWidget({
    super.key,
    this.onLoadNextPage,
    required this.child,
  });

  /// Load-more tolerance in logical pixels. Exact float equality against
  /// [ScrollMetrics.maxScrollExtent] never holds on high-DPI displays where
  /// the resting scroll position lands a fraction of a pixel short (issue
  /// #126), so the trigger compares the clamped [ScrollMetrics.extentAfter]
  /// instead — it is 0 both at the extent and while overscrolled.
  static const double _scrollEndEpsilon = 1.0;

  final VoidCallback? onLoadNextPage;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        final isAtScrollEnd =
            notification.metrics.extentAfter <= _scrollEndEpsilon;
        if (isAtScrollEnd) onLoadNextPage?.call();
        return true;
      },
      child: child,
    );
  }
}
