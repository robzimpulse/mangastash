// Tests for SearchMangaUseCase.clear, focusing on how it behaves per source
// kind: the built-in MangaDex source has no scraping use cases (its getters
// throw UnimplementedError by design), so clear() must skip the per-URL html
// removal instead of touching them. Scraped sources keep the full behavior.
//
// Run with: fvm flutter test test/use_case/manga/search_manga_use_case_test.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/sources/asura_scan_source_external.dart';
import 'package:domain_manga/src/use_case/manga/search_manga_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
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
  late MockHeadlessWebviewUseCase webview;
  late MockMangaDao mangaDao;
  late SearchMangaUseCase useCase;

  setUpAll(() {
    registerFallbackValue(utf8);
    registerFallbackValue(const SearchMangaParameter());
    registerFallbackValue(const <MangaTablesCompanion, List<String>>{});
    registerFallbackValue(const Duration(minutes: 1));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    cacheManager = MockSearchMangaCacheManager();
    htmlCacheManager = MockHtmlCacheManager();
    webview = MockHeadlessWebviewUseCase();
    mangaDao = MockMangaDao();
    // LogBox.log is an extension method, so mocktail cannot intercept it —
    // the validator's card-drop log needs a real Storage behind the mock's
    // field (see CLAUDE.md's LogBox entry).
    final logBox = MockLogBox();
    when(() => logBox.storage).thenReturn(
      analytics.Storage(liveDataStorage: analytics.MemoryStorage()),
    );
    useCase = SearchMangaUseCase(
      mangaRepository: MockMangaRepository(),
      webview: webview,
      converterCacheManager: MockConverterCacheManager(),
      htmlCacheManager: htmlCacheManager,
      searchMangaCacheManager: cacheManager,
      mangaDao: mangaDao,
      logBox: logBox,
    );
    when(() => mangaDao.adds(values: any(named: 'values'))).thenAnswer(
      (_) async => [],
    );
    when(
      () => cacheManager.getFileFromCache(any()),
    ).thenAnswer((_) async => null);
    when(
      () => cacheManager.putFile(
        any(),
        any(),
        key: any(named: 'key'),
        fileExtension: any(named: 'fileExtension'),
        maxAge: any(named: 'maxAge'),
      ),
    ).thenAnswer((_) async => MemoryFileSystem().file('stub'));
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

  group('SearchMangaUseCase.execute (issue #114)', () {
    const browseUrl = 'https://asurascans.com/browse?q=&page=1';

    void stubOpen(String html) {
      when(
        () => webview.open(
          any(),
          scripts: any(named: 'scripts'),
          readyWhenSelectors: any(named: 'readyWhenSelectors'),
          useCache: any(named: 'useCache'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) async => html_parser.parse(html));
    }

    SourceSearchMangaParameter buildParameter() => SourceSearchMangaParameter(
      source: AsuraScanSourceExternal().name,
      parameter: const SearchMangaParameter(page: 1),
    );

    test('a page of cards that all lack required fields is a parse error', () async {
      stubOpen('''
        <html><body>
          <div class="series-card"><h3>No link card</h3></div>
          <div class="series-card"><a href="/comics/x"><img src="cover.jpg"/></a></div>
        </body></html>
      ''');

      final result = await useCase.execute(parameter: buildParameter());

      expect(result, isA<Error<Pagination<Manga>>>());
      final error = (result as Error<Pagination<Manga>>).error;
      expect(error, isA<FailedParsingHtmlException>());
      expect((error as FailedParsingHtmlException).url, browseUrl);
      expect(error.source, 'Asura Scans');
      expect(error.parser, 'searchManga');
      expect(error.missingFields, ['title', 'webUrl']);
      // The broken page never reaches the DB sync or the 30-minute cache.
      verifyNever(() => mangaDao.adds(values: any(named: 'values')));
      verifyNever(
        () => cacheManager.putFile(
          any(),
          any(),
          key: any(named: 'key'),
          fileExtension: any(named: 'fileExtension'),
          maxAge: any(named: 'maxAge'),
        ),
      );
    });

    test('cards missing title or webUrl are dropped, valid ones survive', () async {
      stubOpen('''
        <html><body>
          <div class="series-card">
            <h3><a href="/comics/valid">Valid Title</a></h3>
            <img src="https://asurascans.com/cover.jpg"/>
          </div>
          <div class="series-card"><h3>No link card</h3></div>
        </body></html>
      ''');

      Map<MangaTablesCompanion, List<String>>? syncedValues;
      when(
        () => mangaDao.adds(values: any(named: 'values')),
      ).thenAnswer((invocation) async {
        syncedValues = invocation.namedArguments[#values]
            as Map<MangaTablesCompanion, List<String>>;
        return [];
      });

      final result = await useCase.execute(parameter: buildParameter());

      expect(result, isA<Success<Pagination<Manga>>>());
      // Only the valid card reached the DB write — the link-less card was
      // dropped before sync.
      expect(syncedValues?.keys.single.title.value, 'Valid Title');
      expect(
        syncedValues?.keys.single.webUrl.value,
        'https://asurascans.com/comics/valid',
      );
    });

    test('a page with zero cards stays a genuine no-result success', () async {
      // A search that matched nothing must keep rendering "no results"
      // instead of erroring (per issue #114's decision).
      stubOpen('<html><body></body></html>');

      final result = await useCase.execute(parameter: buildParameter());

      expect(result, isA<Success<Pagination<Manga>>>());
      expect((result as Success<Pagination<Manga>>).data.data, isEmpty);
    });
  });
}
