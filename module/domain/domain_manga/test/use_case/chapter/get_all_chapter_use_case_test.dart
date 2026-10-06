// Tests for GetAllChapterUseCase.execute page loop (issue #118, Task 8):
// the use case fans a single call out to at most [maxPages] SearchChapter
// pages instead of recursing without a bound, and stops early when a page
// fails while keeping the chapters collected so far.
//
// Run with: fvm flutter test test/use_case/chapter/get_all_chapter_use_case_test.dart
import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:domain_manga/src/use_case/chapter/get_all_chapter_use_case.dart';
import 'package:domain_manga/src/use_case/chapter/search_chapter_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchChapterUseCase extends Mock implements SearchChapterUseCase {}

class MockLogBox extends Mock implements LogBox {}

const _mangaId = 'm-1';

const _chapter1 = Chapter(id: 'c-1', mangaId: _mangaId);

const _chapter2 = Chapter(id: 'c-2', mangaId: _mangaId);

Success<Pagination<Chapter>> _page({
  required List<Chapter> chapters,
  required bool hasNextPage,
}) {
  return Success(Pagination<Chapter>(data: chapters, hasNextPage: hasNextPage));
}

void main() {
  late MockSearchChapterUseCase searchChapterUseCase;
  late GetAllChapterUseCase useCase;

  setUpAll(() {
    registerFallbackValue(
      SourceSearchChapterParameter(
        source: MangaDexSourceExternal().name,
        parameter: const SearchChapterParameter(),
        mangaId: _mangaId,
      ),
    );
  });

  setUp(() {
    searchChapterUseCase = MockSearchChapterUseCase();
    // LogBox.log is an extension method, so mocktail cannot intercept it —
    // the real body runs and needs a real Storage behind the mock's field.
    final logBox = MockLogBox();
    when(() => logBox.storage).thenReturn(
      analytics.Storage(liveDataStorage: analytics.MemoryStorage()),
    );
    useCase = GetAllChapterUseCase(
      searchChapterUseCase: searchChapterUseCase,
      logBox: logBox,
    );
  });

  test(
    'stops after maxPages when every page reports a next page',
    timeout: const Timeout(Duration(seconds: 30)),
    () async {
      var calls = 0;
      when(
        () => searchChapterUseCase.execute(
          parameter: any(named: 'parameter'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer((_) async {
        calls++;
        return _page(
          chapters: [Chapter(id: 'c-$calls', mangaId: _mangaId)],
          hasNextPage: true,
        );
      });

      final result = await useCase.execute(
        source: MangaDexSourceExternal(),
        mangaId: _mangaId,
      );

      expect(result.length, GetAllChapterUseCase.maxPages);
      verify(
        () => searchChapterUseCase.execute(
          parameter: any(named: 'parameter'),
          useCache: any(named: 'useCache'),
        ),
      ).called(GetAllChapterUseCase.maxPages);
    },
  );

  test('returns both pages when the second page has no next page', () async {
    var calls = 0;
    when(
      () => searchChapterUseCase.execute(
        parameter: any(named: 'parameter'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer((_) async {
      calls++;
      if (calls == 1) {
        return _page(chapters: [_chapter1], hasNextPage: true);
      }
      return _page(chapters: [_chapter2], hasNextPage: false);
    });

    final result = await useCase.execute(
      source: MangaDexSourceExternal(),
      mangaId: _mangaId,
    );

    expect(result, [_chapter1, _chapter2]);
    verify(
      () => searchChapterUseCase.execute(
        parameter: any(named: 'parameter'),
        useCache: any(named: 'useCache'),
      ),
    ).called(2);
  });

  test('keeps the first page when the second page fails (review focus #5)', () async {
    var calls = 0;
    when(
      () => searchChapterUseCase.execute(
        parameter: any(named: 'parameter'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer((_) async {
      calls++;
      if (calls == 1) {
        return _page(chapters: [_chapter1], hasNextPage: true);
      }
      return Error<Pagination<Chapter>>(Exception('page 2 failed'));
    });

    final result = await useCase.execute(
      source: MangaDexSourceExternal(),
      mangaId: _mangaId,
    );

    expect(result, [_chapter1]);
    verify(
      () => searchChapterUseCase.execute(
        parameter: any(named: 'parameter'),
        useCache: any(named: 'useCache'),
      ),
    ).called(2);
  });

  test('defaults to limit 500 when no parameter is passed', () async {
    when(
      () => searchChapterUseCase.execute(
        parameter: any(named: 'parameter'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer((_) async => _page(chapters: [_chapter1], hasNextPage: false));

    final result = await useCase.execute(
      source: MangaDexSourceExternal(),
      mangaId: _mangaId,
    );

    expect(result, [_chapter1]);
    final captured =
        verify(
          () => searchChapterUseCase.execute(
            parameter: captureAny(named: 'parameter'),
            useCache: any(named: 'useCache'),
          ),
        ).captured;
    expect(captured, hasLength(1));
    final first = captured.first as SourceSearchChapterParameter;
    expect(first.parameter.limit, 500);
  });
}
