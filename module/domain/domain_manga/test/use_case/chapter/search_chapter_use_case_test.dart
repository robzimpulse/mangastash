// Tests for SearchChapterUseCase.execute on scraped sources: the whole
// chapter document is parsed on the first fetch, so the pagination must hand
// the complete list back with hasNextPage: false instead of faking paging
// over an already-complete dataset (issue #116).
//
// Run with: fvm flutter test test/use_case/chapter/search_chapter_use_case_test.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/sources/mangakatana_source_external.dart';
import 'package:domain_manga/src/use_case/chapter/search_chapter_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';

class MockChapterRepository extends Mock implements ChapterRepository {}

class MockHeadlessWebviewUseCase extends Mock implements HeadlessWebviewUseCase {}

class MockConverterCacheManager extends Mock implements ConverterCacheManager {}

class MockHtmlCacheManager extends Mock implements HtmlCacheManager {}

class MockSearchChapterCacheManager extends Mock
    implements SearchChapterCacheManager {}

class MockChapterDao extends Mock implements ChapterDao {}

class MockMangaDao extends Mock implements MangaDao {}

class MockLogBox extends Mock implements LogBox {}

class MockFileInfo extends Mock implements FileInfo {}

class MockCacheFile extends Mock implements File {}

const _mangaId = 'm-1';
const _mangaUrl = 'https://mangakatana.com/manga/one-piece.49';

/// Detail page with [count] chapter rows (desc), mirroring the MangaKatana
/// chapter table the listChapterUseCase parses.
String chapterListHtml(int count) {
  final buffer = StringBuffer('<html><body><table>');
  for (var i = count; i >= 1; i--) {
    buffer.write(
      '<tr><td><div class="chapter">'
      '<a href="$_mangaUrl/c$i">Chapter $i</a></div></td>'
      '<td><div class="update_time">2026-08-0${(i % 9) + 1}</div></td></tr>',
    );
  }
  buffer.write('</table></body></html>');
  return buffer.toString();
}

void main() {
  late MockSearchChapterCacheManager cacheManager;
  late MockChapterDao chapterDao;
  late MockMangaDao mangaDao;
  late MockHeadlessWebviewUseCase webview;
  late SearchChapterUseCase useCase;

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
    webview = MockHeadlessWebviewUseCase();
    // LogBox.log is an extension method, so mocktail cannot intercept it —
    // the real body runs and needs a real Storage behind the mock's field.
    final logBox = MockLogBox();
    when(
      () => logBox.storage,
    ).thenReturn(analytics.Storage(liveDataStorage: analytics.MemoryStorage()));
    useCase = SearchChapterUseCase(
      chapterRepository: MockChapterRepository(),
      webview: webview,
      converterCacheManager: MockConverterCacheManager(),
      htmlCacheManager: MockHtmlCacheManager(),
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
  });

  test('returns the whole chapter list with no next page on first fetch', () async {
    when(
      () => webview.open(
        _mangaUrl,
        scripts: any(named: 'scripts'),
        readyWhenSelectors: any(named: 'readyWhenSelectors'),
        useCache: any(named: 'useCache'),
        timeout: any(named: 'timeout'),
      ),
    ).thenAnswer((_) async => html_parser.parse(chapterListHtml(25)));

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
        source: MangakatanaSourceExternal().name,
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
        webview: MockHeadlessWebviewUseCase(),
        converterCacheManager: MockConverterCacheManager(),
        htmlCacheManager: MockHtmlCacheManager(),
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
}
