import 'package:flutter/widgets.dart';

class PagingScrollController extends ScrollController {
  final void Function(BuildContext) onLoadNextPage;

  PagingScrollController({
    super.initialScrollOffset = 0.0,
    super.keepScrollOffset = true,
    super.debugLabel,
    required this.onLoadNextPage,
  });

  bool onScrollNotification(
    BuildContext context,
    ScrollNotification scrollNotification,
  ) {
    if (!hasClients) return false;

    if (scrollNotification is ScrollEndNotification) {
      final pixels = scrollNotification.metrics.pixels;
      final maxScrollExtent = scrollNotification.metrics.maxScrollExtent;
      if (pixels == maxScrollExtent) {
        onLoadNextPage(context);
      }
    }
    return true;
  }
}
