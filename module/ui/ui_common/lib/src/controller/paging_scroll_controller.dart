import 'package:flutter/widgets.dart';

class PagingScrollController extends ScrollController {
  final void Function(BuildContext) onLoadNextPage;
  final void Function()? onScrolling;

  PagingScrollController({
    super.initialScrollOffset = 0.0,
    super.keepScrollOffset = true,
    super.debugLabel,
    required this.onLoadNextPage,
    this.onScrolling,
  });

  bool onScrollNotification(
    BuildContext context,
    ScrollNotification scrollNotification,
  ) {
    if (!hasClients) return false;
    final isExtendAfterZero = position.extentAfter == 0;
    final isAxisDirectionDown = position.axisDirection == AxisDirection.down;
    final hasReachEnd = isExtendAfterZero && isAxisDirectionDown;
    if (scrollNotification is ScrollStartNotification) {
      onScrolling?.call();
    }
    if (scrollNotification is ScrollEndNotification && hasReachEnd) {
      onLoadNextPage(context);
    }
    return false;
  }
}
