// Tests for SearchChapterUseCase.execute on scraped sources: the whole
// chapter document is parsed on the first fetch, so the pagination must hand
// the complete list back with hasNextPage: false instead of faking paging
// over an already-complete dataset (issue #116). Sources are mocked
// SourceExternals resolved through a mocked SourceRegistry (issue #115): the
// use case reads rows from `chapters(url: await chaptersUrl(webUrl))`, and a
// failed validation or clear() evicts the runner's cached script results.
//
// Run with: fvm flutter test test/use_case/chapter/search_chapter_use_case_test.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/sources/script_source_external.dart';
import 'package:domain_manga/src/use_case/chapter/search_chapter_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/mock_sources.dart';

class MockChapterRepository extends Mock implements ChapterRepository {}

class MockConverterCacheManager extends Mock implements ConverterCacheManager {}

class MockSearchChapterCacheManager extends Mock
    implements SearchChapterCacheManager {}

class MockChapterDao extends Mock implements ChapterDao {}

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

const _mangaId = 'm-1';
const _mangaUrl = 'https://mangakatana.com/manga/one-piece.49';
const _seriesUrl = 'https://weebcentral.com/series/01J76XY7E3JVY2XJGG8VGP46NN';

/// [count] chapter rows (desc), as a chapters() script result.
List<ChapterScrapped> chapterRows(int count) {
  return [
    for (var i = count; i >= 1; i--)
      ChapterScrapped(
        webUrl: '$_mangaUrl/c$i',
        title: 'Chapter $i',
        chapter: '$i',
      ),
  ];
}

void main() {
  late MockSearchChapterCacheManager cacheManager;
  late MockChapterDao chapterDao;
  late MockMangaDao mangaDao;
  late MockRunSourceScriptUseCase runner;
  late MockSourceExternal katana;
  late MockSourceExternal weebCentral;
  late MockSourceRegistry registry;
  late SearchChapterUseCase useCase;

  void stubChapters(
    MockSourceExternal source,
    Future<List<ChapterScrapped>> Function(Invocation) answer,
  ) {
    when(
      () => source.chapters(
        url: any(named: 'url'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer(answer);
  }

  void stubSeriesUrl(String url) {
    when(() => mangaDao.search(ids: any(named: 'ids'))).thenAnswer(
      (_) async => [
        MangaModel(
          manga: MangaDrift(
            id: _mangaId,
            webUrl: url,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ),
      ],
    );
  }

  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(const <ChapterTablesCompanion, List<String>>{});
    registerFallbackValue(MangaModel(manga: null));
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(utf8);
    registerFallbackValue(const SearchChapterParameter());
  });

  setUp(() {
    cacheManager = MockSearchChapterCacheManager();
    chapterDao = MockChapterDao();
    mangaDao = MockMangaDao();
    runner = mockRunner();
    katana = mockScrapedSource(name: 'Manga Katana');
    when(
      () => katana.chaptersUrl(webUrl: any(named: 'webUrl')),
    ).thenAnswer((i) async => i.namedArguments[#webUrl] as String);
    weebCentral = mockScrapedSource(name: 'Weeb Central');
    when(
      () => weebCentral.chaptersUrl(webUrl: any(named: 'webUrl')),
    ).thenAnswer(
      (i) async => '${i.namedArguments[#webUrl]}/full-chapter-list',
    );
    registry = mockRegistry([katana, weebCentral]);
    // LogBox.log is an extension method, so mocktail cannot intercept it —
    // the real body runs and needs a real Storage behind the mock's field.
    final logBox = MockLogBox();
    when(
      () => logBox.storage,
    ).thenReturn(analytics.Storage(liveDataStorage: analytics.MemoryStorage()));
    useCase = SearchChapterUseCase(
      chapterRepository: MockChapterRepository(),
      runner: runner,
      registry: registry,
      converterCacheManager: MockConverterCacheManager(),
      searchChapterCacheManager: cacheManager,
      chapterDao: chapterDao,
      mangaDao: mangaDao,
      logBox: logBox,
    );

    when(() => cacheManager.getFileFromCache(any())).thenAnswer((_) async => null);
    when(
      () => cacheManager.putFile(
        any(),
        any(),
        key: any(named: 'key'),
        fileExtension: any(named: 'fileExtension'),
        maxAge: any(named: 'maxAge'),
      ),
    ).thenAnswer((_) async => MemoryFileSystem().file('stub'));
    stubSeriesUrl(_mangaUrl);
  });

  test('returns the whole chapter list with no next page on first fetch', () async {
    stubChapters(katana, (_) async => chapterRows(25));

    Map<ChapterTablesCompanion, List<String>>? syncedValues;
    when(
      () => chapterDao.adds(values: any(named: 'values')),
    ).thenAnswer((invocation) async {
      syncedValues = invocation.namedArguments[#values]
          as Map<ChapterTablesCompanion, List<String>>;
      return [];
    });

    final result = await useCase.execute(
      parameter: SourceSearchChapterParameter(
        source: 'Manga Katana',
        parameter: const SearchChapterParameter(page: 1, limit: 20),
        mangaId: _mangaId,
      ),
    );

    expect(result, isA<Success<Pagination<Chapter>>>());
    final pagination = (result as Success<Pagination<Chapter>>).data;
    // The document already contained every chapter — there is no second page.
    expect(pagination.hasNextPage, isFalse);
    // And the complete list reached the DB sync, not just the first slice.
    expect(syncedValues?.length, 25);
  });

  test(
    'a corrupt cache file is treated as a miss and refetched (review on #160)',
    () async {
      final repository = MockChapterRepository();
      // LogBox.log is an extension method — the logged-as-miss path needs a
      // real Storage behind the mock's field.
      final logBox = MockLogBox();
      when(() => logBox.storage).thenReturn(
        analytics.Storage(liveDataStorage: analytics.MemoryStorage()),
      );
      final useCase = SearchChapterUseCase(
        chapterRepository: repository,
        runner: runner,
        registry: registry,
        converterCacheManager: MockConverterCacheManager(),
        searchChapterCacheManager: cacheManager,
        chapterDao: chapterDao,
        mangaDao: mangaDao,
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
        () => repository.feed(
          mangaId: any(named: 'mangaId'),
          parameter: any(named: 'parameter'),
        ),
      ).thenThrow(Exception('network failed'));

      final result = await useCase.execute(
        parameter: SourceSearchChapterParameter(
          source: 'Manga Dex',
          parameter: const SearchChapterParameter(page: 1, limit: 20),
          mangaId: _mangaId,
        ),
      );

      expect(result, isA<Error<Pagination<Chapter>>>());
      verify(
        () => repository.feed(
          mangaId: any(named: 'mangaId'),
          parameter: any(named: 'parameter'),
        ),
      ).called(1);
    },
  );

  test(
    'fetches the source chapter-list URL (WeebCentral full-chapter-list, #161)',
    () async {
      stubSeriesUrl(_seriesUrl);

      final openedUrls = <String>[];
      stubChapters(weebCentral, (invocation) async {
        openedUrls.add(invocation.namedArguments[#url] as String);
        return const [
          ChapterScrapped(webUrl: 'https://weebcentral.com/chapters/c1'),
          ChapterScrapped(webUrl: 'https://weebcentral.com/chapters/c2'),
        ];
      });
      when(
        () => chapterDao.adds(values: any(named: 'values')),
      ).thenAnswer((_) async => []);

      final result = await useCase.execute(
        parameter: SourceSearchChapterParameter(
          source: 'Weeb Central',
          parameter: const SearchChapterParameter(page: 1, limit: 20),
          mangaId: _mangaId,
        ),
      );

      expect(result, isA<Success<Pagination<Chapter>>>());
      // The series page itself only carries ~9 latest rows — the use case
      // must fetch the dedicated full-chapter-list endpoint.
      expect(openedUrls, ['$_seriesUrl/full-chapter-list']);
      expect((result as Success<Pagination<Chapter>>).data.total, 2);
    },
  );

  test(
    'an empty chapter parse fails as a parse error instead of syncing an empty list (#114)',
    () async {
      // A correctly parsed series page always carries chapter rows — zero
      // rows means the row anchors drifted. The old behavior returned an
      // empty list that synced into the DB, got cached for 30 minutes,
      // and rendered as "no chapters" with no trace of the real cause.
      stubChapters(katana, (_) async => []);

      final result = await useCase.execute(
        parameter: SourceSearchChapterParameter(
          source: 'Manga Katana',
          parameter: const SearchChapterParameter(page: 1, limit: 20),
          mangaId: _mangaId,
        ),
      );

      expect(result, isA<Error<Pagination<Chapter>>>());
      final error = (result as Error<Pagination<Chapter>>).error;
      expect(error, isA<FailedParsingHtmlException>());
      expect((error as FailedParsingHtmlException).source, 'Manga Katana');
      expect(error.parser, 'chapters');
      expect(error.missingFields, ['chapter rows']);
      // The garbage never reaches the DB sync or the 30-minute cache, and
      // the runner's cached script result for the fetched URL is dropped.
      verifyNever(() => chapterDao.adds(values: any(named: 'values')));
      verify(() => runner.evict(url: _mangaUrl)).called(1);
      verifyNever(
        () => cacheManager.putFile(
          any(),
          any(),
          key: any(named: 'key'),
          fileExtension: any(named: 'fileExtension'),
          maxAge: any(named: 'maxAge'),
        ),
      );
    },
  );

  test(
    'an empty chapter parse reports the URL that was actually fetched (review on #178)',
    () async {
      // WeebCentral serves the chapter list from a dedicated
      // full-chapter-list endpoint, not the series page — the parse error
      // must carry that endpoint or recrawling reopens the wrong page.
      stubSeriesUrl(_seriesUrl);
      stubChapters(weebCentral, (_) async => []);

      final result = await useCase.execute(
        parameter: SourceSearchChapterParameter(
          source: 'Weeb Central',
          parameter: const SearchChapterParameter(page: 1, limit: 20),
          mangaId: _mangaId,
        ),
      );

      expect(result, isA<Error<Pagination<Chapter>>>());
      final error = (result as Error<Pagination<Chapter>>).error
          as FailedParsingHtmlException;
      expect(error.url, '$_seriesUrl/full-chapter-list');
      expect(error.source, 'Weeb Central');
      verify(
        () => runner.evict(url: '$_seriesUrl/full-chapter-list'),
      ).called(1);
    },
  );

  test(
    'clear evicts the script results the fetch actually uses (review on #167)',
    () async {
      // WeebCentral's chapter fetch (and therefore its cached script
      // result) uses the derived full-chapter-list URL, not the series page
      // — evicting the series page would leave the stale entry alive.
      stubSeriesUrl(_seriesUrl);
      when(() => cacheManager.keys).thenAnswer((_) async => {});

      final evicted = <String>[];
      when(() => runner.evict(url: any(named: 'url'))).thenAnswer((
        invocation,
      ) async {
        evicted.add(invocation.namedArguments[#url] as String);
      });

      await useCase.clear(
        parameter: SourceSearchChapterParameter(
          source: 'Weeb Central',
          parameter: const SearchChapterParameter(page: 1, limit: 20),
          mangaId: _mangaId,
        ),
      );

      expect(evicted, ['$_seriesUrl/full-chapter-list']);
    },
  );

  test(
    'clear with the built-in MangaDex source evicts the plain webUrl (review on #167)',
    () async {
      // MangaDexSourceExternal.chaptersUrl throws UnimplementedError by
      // design — clear() must not touch the hook for built-in sources.
      when(() => cacheManager.keys).thenAnswer((_) async => {});

      final evicted = <String>[];
      when(() => runner.evict(url: any(named: 'url'))).thenAnswer((
        invocation,
      ) async {
        evicted.add(invocation.namedArguments[#url] as String);
      });

      await useCase.clear(
        parameter: SourceSearchChapterParameter(
          source: 'Manga Dex',
          parameter: const SearchChapterParameter(page: 1, limit: 20),
          mangaId: _mangaId,
        ),
      );

      expect(evicted, [_mangaUrl]);
    },
  );

  test(
    'a 429 from the chapter feed surfaces as RateLimitException (#118)',
    () async {
      // The MangaDex feed hit the rate limiter — execute() must map the raw
      // DioException to a typed RateLimitException instead of leaking it.
      final repository = MockChapterRepository();
      // LogBox.log is an extension method — the error path needs a real
      // Storage behind the mock's field.
      final logBox = MockLogBox();
      when(() => logBox.storage).thenReturn(
        analytics.Storage(liveDataStorage: analytics.MemoryStorage()),
      );
      final useCase = SearchChapterUseCase(
        chapterRepository: repository,
        runner: runner,
        registry: registry,
        converterCacheManager: MockConverterCacheManager(),
        searchChapterCacheManager: cacheManager,
        chapterDao: chapterDao,
        mangaDao: mangaDao,
        logBox: logBox,
      );

      when(
        () => repository.feed(
          mangaId: any(named: 'mangaId'),
          parameter: any(named: 'parameter'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          response: Response(
            requestOptions: RequestOptions(),
            statusCode: 429,
          ),
        ),
      );

      final result = await useCase.execute(
        parameter: SourceSearchChapterParameter(
          source: 'Manga Dex',
          parameter: const SearchChapterParameter(page: 1, limit: 20),
          mangaId: _mangaId,
        ),
      );

      expect(result, isA<Error<Pagination<Chapter>>>());
      expect(
        (result as Error<Pagination<Chapter>>).error,
        isA<RateLimitException>(),
      );
    },
  );

  group('script identity (issue #115)', () {
    final parameter = SourceSearchChapterParameter(
      source: 'Manga Katana',
      parameter: const SearchChapterParameter(page: 1, limit: 20),
      mangaId: _mangaId,
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
        () => chapterDao.adds(values: any(named: 'values')),
      ).thenAnswer((_) async => []);
      // No chaptersUrl hook: the series page itself is the chapter list.
      when(
        () => runner.runOnBlank(
          code: any(named: 'code'),
          function: any(named: 'function'),
          baseUrl: any(named: 'baseUrl'),
          args: any(named: 'args'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((_) async => null);
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
          value: [
            {'webUrl': '$_mangaUrl/c1', 'title': 'Chapter 1', 'chapter': '1'},
          ],
          elapsed: Duration.zero,
        );
      });
      current = scriptSource(name: 'Manga Katana', body: 'v1', runner: runner);
      when(() => registry.fromName('Manga Katana')).thenAnswer((_) => current);
    });

    test('the same script is served from the cache', () async {
      await useCase.execute(parameter: parameter);
      await useCase.execute(parameter: parameter);

      expect(ranCodes, hasLength(1));
    });

    test('an edited script re-runs instead of serving the old rows', () async {
      await useCase.execute(parameter: parameter);
      // The user edits the script and saves: the registry now resolves the
      // same source name to an adapter holding the new code.
      current = scriptSource(name: 'Manga Katana', body: 'v2', runner: runner);

      await useCase.execute(parameter: parameter);

      expect(ranCodes, hasLength(2));
      expect(ranCodes.first, isNot(ranCodes.last));
      expect(store, hasLength(2));
    });

    test('clear removes the entries of every script version', () async {
      await useCase.execute(parameter: parameter);
      current = scriptSource(name: 'Manga Katana', body: 'v2', runner: runner);
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
