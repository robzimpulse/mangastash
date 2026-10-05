// Tests for GetChapterUseCase on scraped sources (issue #114): a chapter
// reader parse that extracts zero images must fail as a parse error at
// scrape time instead of syncing an image-less chapter whose reader then
// renders nothing.
//
// Run with: fvm flutter test test/use_case/chapter/get_chapter_use_case_test.dart
import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/sources/mangakatana_source_external.dart';
import 'package:domain_manga/src/use_case/chapter/get_chapter_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';

class MockChapterRepository extends Mock implements ChapterRepository {}

class MockAtHomeRepository extends Mock implements AtHomeRepository {}

class MockHeadlessWebviewUseCase extends Mock implements HeadlessWebviewUseCase {}

class MockChapterDao extends Mock implements ChapterDao {}

class MockLogBox extends Mock implements LogBox {}

const _mangaId = 'm-1';
const _chapterId = 'c-1';
const _chapterUrl = 'https://mangakatana.com/manga/one-piece.49/c1';

void main() {
  late MockChapterDao chapterDao;
  late MockHeadlessWebviewUseCase webview;
  late GetChapterUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(const <ChapterTablesCompanion, List<String>>{});
  });

  setUp(() {
    chapterDao = MockChapterDao();
    webview = MockHeadlessWebviewUseCase();
    // LogBox.log is an extension method, so mocktail cannot intercept it —
    // the real body runs and needs a real Storage behind the mock's field
    // (see CLAUDE.md's LogBox entry).
    final logBox = MockLogBox();
    when(
      () => logBox.storage,
    ).thenReturn(analytics.Storage(liveDataStorage: analytics.MemoryStorage()));
    useCase = GetChapterUseCase(
      chapterRepository: MockChapterRepository(),
      atHomeRepository: MockAtHomeRepository(),
      webview: webview,
      chapterDao: chapterDao,
      logBox: logBox,
    );

    when(
      () => chapterDao.search(ids: any(named: 'ids')),
    ).thenAnswer(
      (_) async => [
        ChapterModel(
          chapter: ChapterDrift(
            id: _chapterId,
            webUrl: _chapterUrl,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ),
      ],
    );
    when(
      () => chapterDao.adds(values: any(named: 'values')),
    ).thenAnswer((_) async => []);
  });

  test(
    'an empty image parse fails as a parse error instead of a blank reader (#114)',
    () async {
      when(
        () => webview.open(
          _chapterUrl,
          scripts: any(named: 'scripts'),
          readyWhenSelectors: any(named: 'readyWhenSelectors'),
          useCache: any(named: 'useCache'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer(
        (_) async => html_parser.parse('<html><body></body></html>'),
      );

      final result = await useCase.execute(
        source: MangakatanaSourceExternal(),
        mangaId: _mangaId,
        chapterId: _chapterId,
      );

      expect(result, isA<Error<Chapter>>());
      final error = (result as Error<Chapter>).error;
      expect(error, isA<FailedParsingHtmlException>());
      expect((error as FailedParsingHtmlException).url, _chapterUrl);
      expect(error.source, 'Manga Katana');
      expect(error.parser, 'getChapterImage');
      expect(error.missingFields, ['image urls']);
      // The image-less chapter never reaches the DB sync.
      verifyNever(() => chapterDao.adds(values: any(named: 'values')));
    },
  );
}
