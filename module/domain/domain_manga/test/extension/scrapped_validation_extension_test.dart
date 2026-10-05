// Tests for the scrapped-payload validators (issue #114): source parsers
// never validate what they extracted, so a selector drift returned models
// with null title/webUrl that synced into the DB and only surfaced as a
// DataNotFoundException at reader time. These validators run in the use
// cases between parse() and sync()/cache writes and fail fast with a
// FailedParsingHtmlException carrying source, parser, and missing fields.
//
// Run with: fvm flutter test test/extension/scrapped_validation_extension_test.dart
import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:domain_manga/src/extension/scrapped_validation_extension.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLogBox extends Mock implements LogBox {}

const _url = 'https://asurascans.com/comics/solo-leveling';
const _source = 'Asura Scans';

void main() {
  late MockLogBox logBox;

  setUpAll(() {
    // LogBox.log is an extension method, so mocktail cannot intercept it —
    // the real body runs and needs a real Storage behind the mock's field
    // (see CLAUDE.md's LogBox entry).
    logBox = MockLogBox();
    when(() => logBox.storage).thenReturn(
      analytics.Storage(liveDataStorage: analytics.MemoryStorage()),
    );
  });

  group('requireDetailFields', () {
    test('returns the manga unchanged when the title is present', () {
      final manga = MangaScrapped(title: 'Solo Leveling', webUrl: _url);

      final result = manga.requireDetailFields(source: _source, url: _url);

      expect(result, same(manga));
    });

    test('throws with context when the title is null', () {
      expect(
        () => MangaScrapped(
          title: null,
          webUrl: _url,
        ).requireDetailFields(source: _source, url: _url),
        throwsA(
          isA<FailedParsingHtmlException>()
              .having((e) => e.url, 'url', _url)
              .having((e) => e.source, 'source', _source)
              .having((e) => e.parser, 'parser', 'getManga')
              .having((e) => e.missingFields, 'missingFields', ['title']),
        ),
      );
    });

    test('throws when the title is blank after trimming', () {
      expect(
        () => MangaScrapped(
          title: '   ',
          webUrl: _url,
        ).requireDetailFields(source: _source, url: _url),
        throwsA(isA<FailedParsingHtmlException>()),
      );
    });
  });

  group('requireCardFields', () {
    test('an empty card list is a genuine no-result, not a parse failure', () {
      // A search that matched nothing must keep rendering "no results"
      // instead of erroring (per issue #114's decision).
      final result = <MangaScrapped>[].requireCardFields(
        source: _source,
        url: _url,
        logBox: logBox,
      );

      expect(result, isEmpty);
    });

    test('drops cards missing title or webUrl and keeps the valid ones', () {
      final cards = [
        MangaScrapped(title: 'Valid', webUrl: '$_url/1'),
        MangaScrapped(title: 'No Link'),
        MangaScrapped(webUrl: '$_url/3'),
        MangaScrapped(title: '   ', webUrl: '$_url/4'),
      ];

      final result = cards.requireCardFields(
        source: _source,
        url: _url,
        logBox: logBox,
      );

      expect(result, hasLength(1));
      expect(result.single.title, 'Valid');
    });

    test('cards that all lack required fields are a parse failure', () {
      // The page had cards but none yielded a usable title/webUrl — the
      // extraction broke, and an empty "no results" answer would lie.
      expect(
        () => [
          MangaScrapped(title: 'No Link'),
          MangaScrapped(webUrl: '$_url/2'),
        ].requireCardFields(source: _source, url: _url, logBox: logBox),
        throwsA(
          isA<FailedParsingHtmlException>()
              .having((e) => e.source, 'source', _source)
              .having((e) => e.parser, 'parser', 'searchManga')
              .having(
                (e) => e.missingFields,
                'missingFields',
                ['title', 'webUrl'],
              ),
        ),
      );
    });
  });

  group('requireChapterFields', () {
    test('an empty chapter list is a parse failure, not an empty library', () {
      // A series page always carries its chapter rows when parsed
      // correctly — zero rows means the anchors drifted (the Asura
      // reader bug in issue #114).
      expect(
        () => <ChapterScrapped>[].requireChapterFields(
          source: _source,
          url: _url,
          logBox: logBox,
        ),
        throwsA(
          isA<FailedParsingHtmlException>()
              .having((e) => e.url, 'url', _url)
              .having((e) => e.parser, 'parser', 'listChapter')
              .having((e) => e.missingFields, 'missingFields', [
                'chapter rows',
              ]),
        ),
      );
    });

    test('drops rows missing webUrl and keeps the valid ones', () {
      final rows = [
        ChapterScrapped(title: 'Ch. 1', webUrl: '$_url/c1'),
        ChapterScrapped(title: 'Dead link'),
        ChapterScrapped(title: 'Ch. 3', webUrl: '$_url/c3'),
      ];

      final result = rows.requireChapterFields(
        source: _source,
        url: _url,
        logBox: logBox,
      );

      expect(result, hasLength(2));
      expect(result.map((e) => e.webUrl), ['$_url/c1', '$_url/c3']);
    });

    test('rows that all lack webUrl are a parse failure', () {
      expect(
        () => [
          ChapterScrapped(title: 'Ch. 1'),
        ].requireChapterFields(source: _source, url: _url, logBox: logBox),
        throwsA(isA<FailedParsingHtmlException>()),
      );
    });
  });

  group('requireChapterImages', () {
    test('an empty image list is a parse failure', () {
      expect(
        () => requireChapterImages(<String>[], source: _source, url: _url),
        throwsA(
          isA<FailedParsingHtmlException>()
              .having((e) => e.url, 'url', _url)
              .having((e) => e.parser, 'parser', 'getChapterImage')
              .having((e) => e.missingFields, 'missingFields', [
                'image urls',
              ]),
        ),
      );
    });

    test('returns the images when at least one was extracted', () {
      const images = ['$_url/1.jpg', '$_url/2.jpg'];

      final result = requireChapterImages(
        images,
        source: _source,
        url: _url,
      );

      expect(result, same(images));
    });
  });
}
