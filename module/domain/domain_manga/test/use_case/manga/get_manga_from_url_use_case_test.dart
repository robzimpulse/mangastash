// Tests for GetMangaFromUrlUseCase on scraped sources (issue #114): a
// detail parse that extracts no title must fail as a parse error at
// scrape time instead of syncing a null-title manga into the DB.
//
// Run with: fvm flutter test test/use_case/manga/get_manga_from_url_use_case_test.dart
import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/sources/mangakatana_source_external.dart';
import 'package:domain_manga/src/use_case/manga/get_manga_from_url_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:mocktail/mocktail.dart';

class MockHeadlessWebviewUseCase extends Mock implements HeadlessWebviewUseCase {}

class MockConverterCacheManager extends Mock implements ConverterCacheManager {}

class MockMangaDao extends Mock implements MangaDao {}

class MockLogBox extends Mock implements LogBox {}

const _mangaUrl = 'https://mangakatana.com/manga/one-piece.49';

void main() {
  late MockMangaDao mangaDao;
  late MockHeadlessWebviewUseCase webview;
  late GetMangaFromUrlUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const <MangaTablesCompanion, List<String>>{});
  });

  setUp(() {
    mangaDao = MockMangaDao();
    webview = MockHeadlessWebviewUseCase();
    final logBox = MockLogBox();
    when(() => logBox.storage).thenReturn(
      analytics.Storage(liveDataStorage: analytics.MemoryStorage()),
    );
    useCase = GetMangaFromUrlUseCase(
      webview: webview,
      mangaDao: mangaDao,
      logBox: logBox,
      converterCacheManager: MockConverterCacheManager(),
    );

    when(
      () => mangaDao.search(webUrls: any(named: 'webUrls')),
    ).thenAnswer((_) async => []);
    when(
      () => mangaDao.adds(values: any(named: 'values')),
    ).thenAnswer((_) async => []);
  });

  test(
    'a detail parse without a title fails as a parse error instead of syncing garbage (#114)',
    () async {
      when(
        () => webview.open(
          _mangaUrl,
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
        url: _mangaUrl,
      );

      expect(result, isA<Error<Manga>>());
      final error = (result as Error<Manga>).error;
      expect(error, isA<FailedParsingHtmlException>());
      expect((error as FailedParsingHtmlException).url, _mangaUrl);
      expect(error.source, 'Manga Katana');
      expect(error.parser, 'getManga');
      expect(error.missingFields, ['title']);
      // The null-title manga never reaches the DB sync.
      verifyNever(() => mangaDao.adds(values: any(named: 'values')));
    },
  );
}
