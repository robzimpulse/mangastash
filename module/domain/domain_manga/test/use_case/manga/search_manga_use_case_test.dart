// Tests for SearchMangaUseCase: clear() per source kind — the built-in
// MangaDex source has no scraping hooks (they throw UnimplementedError by
// design), so clear() must skip the per-URL script-result eviction, while
// scraped sources evict the runner cache for their search URL — plus the
// corrupt-cache (#122) and card-validation (#114) paths of execute(). Scraped
// sources are mocked SourceExternals behind a mocked SourceRegistry (#115).
//
// Run with: fvm flutter test test/use_case/manga/search_manga_use_case_test.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/sources/script_source_external.dart';
import 'package:domain_manga/src/use_case/manga/search_manga_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/mock_sources.dart';

class MockMangaRepository extends Mock implements MangaRepository {}

class MockConverterCacheManager extends Mock implements ConverterCacheManager {}

class MockSearchMangaCacheManager extends Mock
    implements SearchMangaCacheManager {}

class MockMangaDao extends Mock implements MangaDao {}

class MockLogBox extends Mock implements LogBox {}

class MockFileInfo extends Mock implements FileInfo {}

class MockCacheFile extends Mock implements File {}

/// In-memory cache entry: only the file read the use case performs.
class _StoredFile extends Fake implements File {
  _StoredFile(this.text);

  final String text;

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async => text;
}

class _StoredInfo extends Fake implements FileInfo {
  _StoredInfo(String text) : file = _StoredFile(text);

  @override
  final File file;
}

void main() {
  const browseUrl = 'https://asurascans.com/browse?q=&page=1';

  late MockSearchMangaCacheManager cacheManager;
  late MockRunSourceScriptUseCase runner;
  late MockSourceExternal asura;
  late MockSourceRegistry registry;
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
    runner = mockRunner();
    asura = mockScrapedSource(
      name: 'Asura Scans',
      baseUrl: 'https://asurascans.com',
    );
    when(
      () => asura.searchUrl(parameter: any(named: 'parameter')),
    ).thenAnswer((_) async => browseUrl);
    registry = mockRegistry([asura]);
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
      runner: runner,
      registry: registry,
      converterCacheManager: MockConverterCacheManager(),
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
      // throwing on the source hook.
      verify(() => cacheManager.removeFile(any())).called(1);
      // Nothing is evicted from the runner cache (resolving the search URL
      // for MangaDex is exactly what would throw UnimplementedError).
      verifyNever(() => runner.evict(url: any(named: 'url')));
    });

    test('evicts the script results of a scraped source', () async {
      final parameter = SourceSearchMangaParameter(
        source: 'Asura Scans',
        parameter: const SearchMangaParameter(page: 1),
      );
      when(
        () => cacheManager.keys,
      ).thenAnswer((_) async => {parameter.toJsonString()});

      await useCase.clear(parameter: parameter);

      verify(() => runner.evict(url: browseUrl)).called(1);
    });

    test('a failing searchUrl script does not break clear', () async {
      final parameter = SourceSearchMangaParameter(
        source: 'Asura Scans',
        parameter: const SearchMangaParameter(page: 1),
      );
      when(
        () => cacheManager.keys,
      ).thenAnswer((_) async => {parameter.toJsonString()});
      when(
        () => asura.searchUrl(parameter: any(named: 'parameter')),
      ).thenThrow(
        const SourceScriptException(function: 'searchUrl', message: 'boom'),
      );

      await expectLater(useCase.clear(parameter: parameter), completes);
      verify(() => cacheManager.removeFile(any())).called(1);
    });

    test('removes files for a source that is no longer in the registry', () async {
      // A custom source deleted from the registry still owns cache files;
      // clear must remove them instead of silently doing nothing — only the
      // script-result eviction depends on the registry (review on #194).
      final parameter = SourceSearchMangaParameter(
        source: 'Ghost',
        parameter: const SearchMangaParameter(page: 1),
      );
      when(
        () => cacheManager.keys,
      ).thenAnswer((_) async => {parameter.toJsonString()});
      when(() => registry.fromName('Ghost')).thenAnswer((_) => null);

      await useCase.clear(parameter: parameter);

      verify(() => cacheManager.removeFile(any())).called(1);
      verifyNever(() => runner.evict(url: any(named: 'url')));
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
        runner: runner,
        registry: registry,
        converterCacheManager: MockConverterCacheManager(),
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
    void stubSearch(List<MangaScrapped> items) {
      when(
        () => asura.search(
          url: any(named: 'url'),
          searchTerm: any(named: 'searchTerm'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer(
        (_) async => SearchResultScrapped(items: items, hasNextPage: true),
      );
    }

    SourceSearchMangaParameter buildParameter() => SourceSearchMangaParameter(
      source: 'Asura Scans',
      parameter: const SearchMangaParameter(page: 1),
    );

    test('a page of cards that all lack required fields is a parse error', () async {
      stubSearch(const [
        MangaScrapped(title: 'No link card'),
        MangaScrapped(webUrl: 'https://asurascans.com/comics/x'),
      ]);

      final result = await useCase.execute(parameter: buildParameter());

      expect(result, isA<Error<Pagination<Manga>>>());
      final error = (result as Error<Pagination<Manga>>).error;
      expect(error, isA<FailedParsingHtmlException>());
      expect((error as FailedParsingHtmlException).url, browseUrl);
      expect(error.source, 'Asura Scans');
      expect(error.parser, 'search');
      expect(error.missingFields, ['title', 'webUrl']);
      // The broken page never reaches the DB sync or the 30-minute cache,
      // and the runner's cached script result is dropped.
      verifyNever(() => mangaDao.adds(values: any(named: 'values')));
      verify(() => runner.evict(url: browseUrl)).called(1);
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
      stubSearch(const [
        MangaScrapped(
          title: 'Valid Title',
          webUrl: 'https://asurascans.com/comics/valid',
          coverUrl: 'https://asurascans.com/cover.jpg',
        ),
        MangaScrapped(title: 'No link card'),
      ]);

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
      expect((result as Success<Pagination<Manga>>).data.hasNextPage, isTrue);
      expect(result.data.sourceUrl, browseUrl);
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
      stubSearch(const []);

      final result = await useCase.execute(parameter: buildParameter());

      expect(result, isA<Success<Pagination<Manga>>>());
      expect((result as Success<Pagination<Manga>>).data.data, isEmpty);
    });
  });

  group('SearchMangaUseCase.execute script identity (issue #115)', () {
    const parameter = SourceSearchMangaParameter(
      source: 'Asura Scans',
      parameter: SearchMangaParameter(page: 1),
    );

    late Map<String, String> store;
    late List<String> ranCodes;
    late ScriptSourceExternal current;

    setUp(() {
      store = {};
      ranCodes = [];
      when(() => cacheManager.getFileFromCache(any())).thenAnswer((i) async {
        final text = store[i.positionalArguments.first as String];
        return text == null ? null : _StoredInfo(text);
      });
      when(
        () => cacheManager.putFile(
          any(),
          any(),
          key: any(named: 'key'),
          fileExtension: any(named: 'fileExtension'),
          maxAge: any(named: 'maxAge'),
        ),
      ).thenAnswer((i) async {
        store[i.namedArguments[#key] as String] = utf8.decode(
          i.positionalArguments[1] as List<int>,
        );
        return MemoryFileSystem().file('stub');
      });
      when(
        () => runner.runOnBlank(
          code: any(named: 'code'),
          function: any(named: 'function'),
          baseUrl: any(named: 'baseUrl'),
          args: any(named: 'args'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) async => browseUrl);
      when(
        () => runner.runOnPage(
          url: any(named: 'url'),
          code: any(named: 'code'),
          function: any(named: 'function'),
          baseUrl: any(named: 'baseUrl'),
          searchTerm: any(named: 'searchTerm'),
          timeout: any(named: 'timeout'),
          useCache: any(named: 'useCache'),
          captureHtml: any(named: 'captureHtml'),
        ),
      ).thenAnswer((i) async {
        ranCodes.add(i.namedArguments[#code] as String);
        return const ScriptRunResult(
          value: {
            'items': [
              {'title': 'Solo', 'webUrl': 'https://asurascans.com/comics/solo'},
            ],
          },
          elapsed: Duration.zero,
        );
      });
      current = scriptSource(name: 'Asura Scans', body: 'v1', runner: runner);
      when(() => registry.fromName('Asura Scans')).thenAnswer((_) => current);
    });

    test('the same script is served from the cache', () async {
      await useCase.execute(parameter: parameter);
      await useCase.execute(parameter: parameter);

      expect(ranCodes, hasLength(1));
    });

    test('an edited script re-runs instead of serving the old cards', () async {
      await useCase.execute(parameter: parameter);
      // The user edits the script and saves: the registry now resolves the
      // same source name to an adapter holding the new code.
      current = scriptSource(name: 'Asura Scans', body: 'v2', runner: runner);

      await useCase.execute(parameter: parameter);

      expect(ranCodes, hasLength(2));
      expect(ranCodes.first, isNot(ranCodes.last));
      expect(store, hasLength(2));
    });

    test('clear removes the entries of every script version', () async {
      await useCase.execute(parameter: parameter);
      current = scriptSource(name: 'Asura Scans', body: 'v2', runner: runner);
      await useCase.execute(parameter: parameter);
      when(() => cacheManager.keys).thenAnswer((_) async => store.keys.toSet());
      when(() => cacheManager.removeFile(any())).thenAnswer((_) async {});

      await useCase.clear(parameter: parameter);

      for (final key in store.keys) {
        verify(() => cacheManager.removeFile(key)).called(1);
      }
    });
  });
}
