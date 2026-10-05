// Widget tests for [NextPageNotificationWidget]'s load-more trigger.
//
// The trigger must treat the scroll position as "at the end" when it is
// within a small rounding tolerance of maxScrollExtent — exact float
// equality (`pixels == maxScrollExtent`) never holds on high-DPI displays
// where the final resting position lands a fraction of a logical pixel
// short of the extent (issue #126).
//
// Usage: run from `module/ui/ui_common` with `fvm flutter test`.
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_common/ui_common.dart';

void main() {
  Widget harness({VoidCallback? onLoadNextPage}) {
    return NextPageNotificationWidget(
      onLoadNextPage: onLoadNextPage,
      child: const SizedBox(width: 100, height: 100),
    );
  }

  /// Dispatches a [ScrollEndNotification] carrying the given scroll
  /// position so the listener under test evaluates exactly these metrics.
  void dispatchScrollEnd(WidgetTester tester, {required double pixels}) {
    final context = tester.element(
      find.byType(NotificationListener<ScrollEndNotification>),
    );
    ScrollEndNotification(
      metrics: FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 100,
        pixels: pixels,
        viewportDimension: 300,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 3.0,
      ),
      context: context,
    ).dispatch(context);
  }

  testWidgets('fires load-more when resting a fraction below the extent', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(harness(onLoadNextPage: () => calls++));

    // High-DPI rounding: 0.5 logical pixels short of the extent.
    dispatchScrollEnd(tester, pixels: 99.5);

    expect(calls, 1, reason: 'rounding shortfall must still trigger paging');
  });

  testWidgets('fires load-more when overscrolled beyond the extent', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(harness(onLoadNextPage: () => calls++));

    dispatchScrollEnd(tester, pixels: 103);

    expect(calls, 1, reason: 'clamped overscroll has extentAfter == 0');
  });

  testWidgets('does not fire when clearly away from the end', (tester) async {
    var calls = 0;
    await tester.pumpWidget(harness(onLoadNextPage: () => calls++));

    dispatchScrollEnd(tester, pixels: 50);

    expect(calls, 0);
  });
}
