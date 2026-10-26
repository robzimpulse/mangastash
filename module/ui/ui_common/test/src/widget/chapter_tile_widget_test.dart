// Regression tests for the chapter tile display mode (issue #200):
// the Display tab of the filter sheet saves `ChapterConfig.display`, but
// nothing read it when rendering — `ChapterTileWidget.chapter` always built
// the combined "Chapter N - title" title, so switching between Source Title
// and Chapter Number changed the radio but never the list.
//
// Usage: run from `module/ui/ui_common` with `fvm flutter test` (or plain
// `flutter test`).
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_common/ui_common.dart';

void main() {
  const chapter = Chapter(id: 'a', chapter: '6', title: 'Volume 6');

  group('ChapterTileWidget.displayTitle', () {
    test('source title mode shows the title, falling back to the number', () {
      expect(
        ChapterTileWidget.displayTitle(chapter, ChapterDisplayEnum.title),
        'Volume 6',
      );
      expect(
        ChapterTileWidget.displayTitle(
          const Chapter(id: 'b', chapter: '7'),
          ChapterDisplayEnum.title,
        ),
        'Chapter 7',
      );
    });

    test('chapter number mode shows the number only', () {
      expect(
        ChapterTileWidget.displayTitle(chapter, ChapterDisplayEnum.chapter),
        'Chapter 6',
      );
      expect(
        ChapterTileWidget.displayTitle(
          const Chapter(id: 'c', title: 'No number'),
          ChapterDisplayEnum.chapter,
        ),
        'No number',
      );
    });

    test('no display mode keeps the legacy combined format', () {
      expect(
        ChapterTileWidget.displayTitle(chapter, null),
        'Chapter 6 - Volume 6',
      );
    });
  });

  group('ChapterTileWidget.chapter renders the configured mode', () {
    Widget pump(ChapterDisplayEnum? display) {
      return MaterialApp(
        home: Material(
          child: ChapterTileWidget.chapter(chapter: chapter, display: display),
        ),
      );
    }

    testWidgets('source title mode renders the title', (tester) async {
      await tester.pumpWidget(pump(ChapterDisplayEnum.title));
      expect(find.text('Volume 6'), findsOneWidget);
      expect(find.textContaining('Chapter 6 - Volume 6'), findsNothing);
    });

    testWidgets('chapter number mode renders the number only', (tester) async {
      await tester.pumpWidget(pump(ChapterDisplayEnum.chapter));
      expect(find.text('Chapter 6'), findsOneWidget);
      expect(find.text('Volume 6'), findsNothing);
    });

    testWidgets('unconfigured callers keep the legacy combined title', (
      tester,
    ) async {
      await tester.pumpWidget(pump(null));
      expect(find.text('Chapter 6 - Volume 6'), findsOneWidget);
    });
  });
}
