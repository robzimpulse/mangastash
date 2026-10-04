// Tests for SearchMangaUseCase.clear, focusing on how it behaves per source
// kind: the built-in MangaDex source has no scraping use cases (its getters
// throw UnimplementedError by design), so clear() must skip the per-URL html
// removal instead of touching them. Scraped sources keep the full behavior.
//
// Run with: fvm flutter test test/use_case/manga/search_manga_use_case_test.dart
import 'dart:convert';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/use_case/manga/search_manga_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:file/file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';

class MockMangaRepository extends Mock implements MangaRepository {}

class MockHeadlessWebviewUseCase extends Mock implements HeadlessWebviewUseCase {}

class MockConverterCacheManager extends Mock implements ConverterCacheManager {}

class MockHtmlCacheManager extends Mock implements HtmlCacheManager {}

class MockSearchMangaCacheManager extends Mock
    implements SearchMangaCacheManager {}

class MockMangaDao extends Mock implements MangaDao {}

class MockLogBox extends Mock implements LogBox {}

class MockFileInfo extends Mock implements FileInfo {}

class MockCacheFile extends Mock implements File {}

void main() {
  late MockSearchMangaCacheManager cacheManager;
  late MockHtmlCacheManager htmlCacheManager;
  late SearchMangaUseCase useCase;

  setUpAll(() {
    registerFallbackValue(utf8);
    registerFallbackValue(const SearchMangaParameter());
  });

  setUp(() {
    cacheManager = MockSearchMangaCacheManager();
    htmlCacheManager = MockHtmlCacheManager();
    useCase = SearchMangaUseCase(
      mangaRepository: MockMangaRepository(),
      webview: MockHeadlessWebviewUseCase(),
      converterCacheManager: MockConverterCacheManager(),
      htmlCacheManager: htmlCacheManager,
      searchMangaCacheManager: cacheManager,
      mangaDao: MockMangaDao(),
      logBox: MockLogBox(),
    );
    when(
      () => htmlCacheManager.removeFile(any()),
    ).thenAnswer((_) async {});
    when(
      () => cacheManager.removeFile(any()),
    ).thenAnswer((_) async {});
  });

  group('SearchMangaUseCase.clear', () {
    test('completes for the built-in MangaDex source', () async {
      final parameter = SourceSearchMangaParameter(
        source: 'Manga Dex',
        parameter: const SearchMangaParameter(page: 1),
      );
      when(
        () => cacheManager.keys,
      ).thenAnswer((_) async => {parameter.toJsonString()});

      await expectLater(useCase.clear(parameter: parameter), completes);

      // The cache-entry eviction still runs — the loop completed instead of
      // throwing on the source getter.
      verify(() => cacheManager.removeFile(any())).called(1);
      // The source icon is evicted unconditionally; nothing else may be
      // evicted from the html cache (resolving the search URL for MangaDex
      // is exactly what used to throw UnimplementedError).
      verify(
        () => htmlCacheManager.removeFile('https://www.mangadex.org/favicon.ico'),
      ).called(1);
      verifyNever(
        () => htmlCacheManager.removeFile(
          any(that: isNot('https://www.mangadex.org/favicon.ico')),
        ),
      );
    });

    test('removes the html page for a scraped source', () async {
      final parameter = SourceSearchMangaParameter(
        source: 'Asura Scans',
        parameter: const SearchMangaParameter(page: 1),
      );
      when(
        () => cacheManager.keys,
      ).thenAnswer((_) async => {parameter.toJsonString()});

      await useCase.clear(parameter: parameter);

      verify(
        () => htmlCacheManager.removeFile('https://asurascans.com/browse?q=&page=1'),
      ).called(1);
    });
  });

  group('SearchMangaUseCase.execute (issue #122)', () {
    test('a corrupt cache file is treated as a miss and refetched', () async {
      // LogBox.log is an extension method, so mocktail cannot intercept it
      // — the corrupt-cache path now logs, which needs a real Storage
      // behind the mock's field (see CLAUDE.md's LogBox entry).
      final logBox = MockLogBox();
      when(() => logBox.storage).thenReturn(
        analytics.Storage(liveDataStorage: analytics.MemoryStorage()),
      );
      final repository = MockMangaRepository();
      final useCase = SearchMangaUseCase(
        mangaRepository: repository,
        webview: MockHeadlessWebviewUseCase(),
        converterCacheManager: MockConverterCacheManager(),
        htmlCacheManager: htmlCacheManager,
        searchMangaCacheManager: cacheManager,
        mangaDao: MockMangaDao(),
        logBox: logBox,
      );

      // A cache entry exists, but its file cannot be read (corrupt or
      // partially written) — readAsString throws before any JSON parsing.
      final file = MockCacheFile();
      when(
        () => file.readAsString(encoding: any(named: 'encoding')),
      ).thenAnswer((_) async => throw Exception('corrupt cache file'));
      final info = MockFileInfo();
      when(() => info.file).thenReturn(file);
      when(
        () => cacheManager.getFileFromCache(any()),
      ).thenAnswer((_) async => info);
      // The network fetch is reached but fails — proving the cache failure
      // fell through to the network path instead of escaping execute().
      when(
        () => repository.search(parameter: any(named: 'parameter')),
      ).thenThrow(Exception('network failed'));

      final result = await useCase.execute(
        parameter: const SourceSearchMangaParameter(
          source: 'Manga Dex',
          parameter: SearchMangaParameter(page: 1),
        ),
      );

      expect(result, isA<Error<Pagination<Manga>>>());
      expect((result as Error<Pagination<Manga>>).error, isA<Exception>());
      verify(
        () => repository.search(parameter: any(named: 'parameter')),
      ).called(1);
    });
  });
}
