// Tests for SearchMangaUseCase.clear, focusing on how it behaves per source
// kind: the built-in MangaDex source has no scraping use cases (its getters
// throw UnimplementedError by design), so clear() must skip the per-URL html
// removal instead of touching them. Scraped sources keep the full behavior.
//
// Run with: fvm flutter test test/use_case/manga/search_manga_use_case_test.dart
import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/use_case/manga/search_manga_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
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

void main() {
  late MockSearchMangaCacheManager cacheManager;
  late MockHtmlCacheManager htmlCacheManager;
  late SearchMangaUseCase useCase;

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
}
