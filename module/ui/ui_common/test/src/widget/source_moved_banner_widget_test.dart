// Widget tests for SourceMovedBannerWidget (issue #206): the banner shown on
// a manga detail screen whose source moved to another domain renders the
// pinned copy verbatim.
//
// Usage: run with `fvm flutter test test/src/widget/source_moved_banner_widget_test.dart`
// from module/ui/ui_common.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_common/src/widget/source_moved_banner_widget.dart';

void main() {
  testWidgets('renders the pinned moved-source copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SourceMovedBannerWidget(sourceName: 'A', host: 'old.example'),
        ),
      ),
    );

    expect(
      find.text(
        'Source moved — A no longer serves old.example. '
        "Showing your saved copy; this manga can't be updated.",
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.link_off), findsOneWidget);
  });
}
