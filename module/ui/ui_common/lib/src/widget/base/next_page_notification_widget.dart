import 'package:flutter/widgets.dart';

class NextPageNotificationWidget extends StatelessWidget {
  const NextPageNotificationWidget({
    super.key,
    this.onLoadNextPage,
    required this.child,
  });

  final VoidCallback? onLoadNextPage;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        final pixels = notification.metrics.pixels;
        final maxScrollExtent = notification.metrics.maxScrollExtent;
        if (pixels == maxScrollExtent) onLoadNextPage?.call();
        return true;
      },
      child: child,
    );
  }
}
