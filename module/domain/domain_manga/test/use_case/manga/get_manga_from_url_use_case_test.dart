// Tests for GetMangaFromUrlUseCase on scraped sources (issue #114): a
// detail parse that extracts no title must fail as a parse error at
// scrape time instead of syncing a null-title manga into the DB. The source
// is a mocked SourceExternal (issue #115); the failed validation must also
// evict the runner's cached script result.
//
// Run with: fvm flutter test test/use_case/manga/get_manga_from_url_use_case_test.dart
import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/use_case/manga/get_manga_from_url_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/mock_sources.dart';

class MockConverterCacheManager extends Mock implements ConverterCacheManager {}

class MockMangaDao extends Mock implements MangaDao {}

class MockLogBox extends Mock implements LogBox {}

const _mangaUrl = 'https://mangakatana.com/manga/one-piece.49';

void main() {
  late MockMangaDao mangaDao;
  late MockRunSourceScriptUseCase runner;
  late MockSourceExternal source;
  late GetMangaFromUrlUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const <MangaTablesCompanion, List<String>>{});
  });

  setUp(() {
    mangaDao = MockMangaDao();
    runner = mockRunner();
    source = mockScrapedSource(name: 'Manga Katana');
    final logBox = MockLogBox();
    when(() => logBox.storage).thenReturn(
      analytics.Storage(liveDataStorage: analytics.MemoryStorage()),
    );
    useCase = GetMangaFromUrlUseCase(
      runner: runner,
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
        () => source.manga(url: _mangaUrl, useCache: any(named: 'useCache')),
      ).thenAnswer((_) async => const MangaScrapped());

      final result = await useCase.execute(source: source, url: _mangaUrl);

      expect(result, isA<Error<Manga>>());
      final error = (result as Error<Manga>).error;
      expect(error, isA<FailedParsingHtmlException>());
      expect((error as FailedParsingHtmlException).url, _mangaUrl);
      expect(error.source, 'Manga Katana');
      expect(error.parser, 'manga');
      expect(error.missingFields, ['title']);
      // The null-title manga never reaches the DB sync, and the cached
      // script result behind it is dropped.
      verifyNever(() => mangaDao.adds(values: any(named: 'values')));
      verify(() => runner.evict(url: _mangaUrl)).called(1);
    },
  );
}
