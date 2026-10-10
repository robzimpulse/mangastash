// Tests for GetMangaUseCase on scraped sources (issue #114): a detail
// parse that extracts no title must fail as a parse error at scrape time
// instead of syncing a null-title manga into the DB that later surfaces
// as a DataNotFoundException. The source is a mocked SourceExternal
// returning an untitled MangaScrapped (issue #115); the failed validation
// must also evict the runner's cached script result.
//
// Run with: fvm flutter test test/use_case/manga/get_manga_use_case_test.dart
import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/use_case/manga/get_manga_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/mock_sources.dart';

class MockMangaService extends Mock implements MangaService {}

class MockConverterCacheManager extends Mock implements ConverterCacheManager {}

class MockMangaDao extends Mock implements MangaDao {}

class MockLogBox extends Mock implements LogBox {}

const _mangaId = 'm-1';
const _mangaUrl = 'https://mangakatana.com/manga/one-piece.49';

void main() {
  late MockMangaDao mangaDao;
  late MockRunSourceScriptUseCase runner;
  late MockSourceExternal source;
  late GetMangaUseCase useCase;

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
    useCase = GetMangaUseCase(
      runner: runner,
      converterCacheManager: MockConverterCacheManager(),
      mangaService: MockMangaService(),
      mangaDao: mangaDao,
      logBox: logBox,
    );

    // The DB row carries a webUrl but no title — propertiesFilled is
    // false, so execute() rescrapes the detail page.
    when(() => mangaDao.search(ids: any(named: 'ids'))).thenAnswer(
      (_) async => [
        MangaModel(
          manga: MangaDrift(
            id: _mangaId,
            webUrl: _mangaUrl,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ),
      ],
    );
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

      final result = await useCase.execute(source: source, mangaId: _mangaId);

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
