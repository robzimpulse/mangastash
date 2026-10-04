// Tests for BrowseMangaScreenCubit.recrawl: the built-in MangaDex source has
// no scraping use cases (getters throw UnimplementedError by design), so
// recrawl must pass an empty scripts list instead of crashing.
//
// Run with: fvm flutter test test/src/browse_manga_screen/browse_manga_screen_cubit_test.dart
import 'dart:async';

import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ui_browse/src/browse_manga_screen/browse_manga_screen_cubit.dart';
import 'package:ui_browse/src/browse_manga_screen/browse_manga_screen_state.dart';

import '../../mock/mock.dart';

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeBuildContext());
    registerFallbackValue(
      const SourceSearchMangaParameter(source: '', parameter: SearchMangaParameter()),
    );
    registerFallbackValue(MangaDexSourceExternal());
  });

  test('recrawl passes no scripts for the built-in MangaDex source', () async {
    final recrawlUseCase = MockRecrawlUseCase();
    final searchMangaUseCase = MockSearchMangaUseCase();
    final getTagsUseCase = MockGetTagsUseCase();
    when(
      () => getTagsUseCase.execute(source: any(named: 'source'), useCache: any(named: 'useCache')),
    ).thenAnswer(
      (_) async => Error<List<Tag>>(Exception('stubbed off in test')),
    );
    when(
      () => searchMangaUseCase.clear(parameter: any(named: 'parameter')),
    ).thenAnswer((_) async {});
    when(
      () => searchMangaUseCase.execute(
        parameter: any(named: 'parameter'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer(
      (_) async => Error<Pagination<Manga>>(Exception('stubbed off in test')),
    );
    when(
      () => recrawlUseCase.execute(
        context: any(named: 'context'),
        url: any(named: 'url'),
        scripts: any(named: 'scripts'),
      ),
    ).thenAnswer((_) async {});

    final cubit = BrowseMangaScreenCubit(
      initialState: BrowseMangaScreenState(
        source: MangaDexSourceExternal(),
      ),
      searchMangaUseCase: searchMangaUseCase,
      addToLibraryUseCase: MockAddToLibraryUseCase(),
      removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
      listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
      prefetchMangaUseCase: MockPrefetchMangaUseCase(),
      listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
      getTagsUseCase: getTagsUseCase,
      recrawlUseCase: recrawlUseCase,
    );
    addTearDown(cubit.close);

    cubit.recrawl(context: _FakeBuildContext(), url: 'https://www.mangadex.org/');
    await pumpEventQueue();

    final verification = verify(
      () => recrawlUseCase.execute(
        context: captureAny(named: 'context'),
        url: captureAny(named: 'url'),
        scripts: captureAny(named: 'scripts'),
      ),
    );
    verification.called(1);
    expect(verification.captured[2] as List<String>, isEmpty);
  });

  test('recrawl passes the source scripts through for a scraped source', () async {
    final recrawlUseCase = MockRecrawlUseCase();
    final searchMangaUseCase = MockSearchMangaUseCase();
    final getTagsUseCase = MockGetTagsUseCase();
    when(
      () => getTagsUseCase.execute(
        source: any(named: 'source'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer(
      (_) async => Error<List<Tag>>(Exception('stubbed off in test')),
    );
    when(
      () => searchMangaUseCase.clear(parameter: any(named: 'parameter')),
    ).thenAnswer((_) async {});
    when(
      () => searchMangaUseCase.execute(
        parameter: any(named: 'parameter'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer(
      (_) async => Error<Pagination<Manga>>(Exception('stubbed off in test')),
    );
    when(
      () => recrawlUseCase.execute(
        context: any(named: 'context'),
        url: any(named: 'url'),
        scripts: any(named: 'scripts'),
      ),
    ).thenAnswer((_) async {});

    final cubit = BrowseMangaScreenCubit(
      initialState: BrowseMangaScreenState(
        source: FakeScrapedSourceExternal(),
      ),
      searchMangaUseCase: searchMangaUseCase,
      addToLibraryUseCase: MockAddToLibraryUseCase(),
      removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
      listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
      prefetchMangaUseCase: MockPrefetchMangaUseCase(),
      listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
      getTagsUseCase: getTagsUseCase,
      recrawlUseCase: recrawlUseCase,
    );
    addTearDown(cubit.close);

    cubit.recrawl(context: _FakeBuildContext(), url: 'https://scraped.example.com/browse');
    await pumpEventQueue();

    final verification = verify(
      () => recrawlUseCase.execute(
        context: captureAny(named: 'context'),
        url: captureAny(named: 'url'),
        scripts: captureAny(named: 'scripts'),
      ),
    );
    verification.called(1);
    expect(
      verification.captured[2] as List<String>,
      FakeScrapedSourceExternal.searchScripts,
    );
  });

  group('BrowseMangaScreenCubit.init/next (issues #122 & #123)', () {
    late MockSearchMangaUseCase searchMangaUseCase;
    late BrowseMangaScreenCubit cubit;

    setUp(() {
      searchMangaUseCase = MockSearchMangaUseCase();
      final getTagsUseCase = MockGetTagsUseCase();
      when(
        () => getTagsUseCase.execute(
          source: any(named: 'source'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer(
        (_) async => Error<List<Tag>>(Exception('stubbed off in test')),
      );
      when(
        () => searchMangaUseCase.clear(parameter: any(named: 'parameter')),
      ).thenAnswer((_) async {});
      when(
        () => searchMangaUseCase.execute(
          parameter: any(named: 'parameter'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer(
        (_) async => Error<Pagination<Manga>>(Exception('stubbed off in test')),
      );

      cubit = BrowseMangaScreenCubit(
        initialState: BrowseMangaScreenState(
          source: MangaDexSourceExternal(),
        ),
        searchMangaUseCase: searchMangaUseCase,
        addToLibraryUseCase: MockAddToLibraryUseCase(),
        removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
        listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
        prefetchMangaUseCase: MockPrefetchMangaUseCase(),
        listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
        prefetchChapterUseCase: MockPrefetchChapterUseCase(),
        listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
        getTagsUseCase: getTagsUseCase,
        recrawlUseCase: MockRecrawlUseCase(),
      );
      addTearDown(cubit.close);
    });

    // Re-stubs execute to hand out one completer per call, in call order.
    List<Completer<Result<Pagination<Manga>>>> completeInCallOrder() {
      final responses = <Completer<Result<Pagination<Manga>>>>[];
      when(
        () => searchMangaUseCase.execute(
          parameter: any(named: 'parameter'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer((_) {
        final response = Completer<Result<Pagination<Manga>>>();
        responses.add(response);
        return response.future;
      });
      return responses;
    }

    test(
      'init resets isLoading and emits an error when the search throws (#122)',
      () async {
        when(
          () => searchMangaUseCase.execute(
            parameter: any(named: 'parameter'),
            useCache: any(named: 'useCache'),
          ),
        ).thenThrow(Exception('corrupt cache escaped the use case'));

        await cubit.init();

        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.error, isA<Exception>());
      },
    );

    test('next resets isPagingNextPage when the fetch throws (#122)', () async {
      cubit.emit(cubit.state.copyWith(hasNextPage: true));
      when(
        () => searchMangaUseCase.execute(
          parameter: any(named: 'parameter'),
          useCache: any(named: 'useCache'),
        ),
      ).thenThrow(Exception('fetch failed'));

      await cubit.next();

      expect(cubit.state.isPagingNextPage, isFalse);
      expect(cubit.state.error, isA<Exception>());
    });

    test(
      'drops a stale init response superseded by a newer init (#123)',
      () async {
        final responses = completeInCallOrder();

        final first = cubit.init();
        await pumpEventQueue();
        final second = cubit.init();
        await pumpEventQueue();
        expect(responses, hasLength(2));

        // The newer fetch lands first…
        responses[1].complete(
          Success(
            Pagination(
              data: const [Manga(id: 'fresh')],
              page: 7,
              limit: 20,
              total: 40,
            ),
          ),
        );
        await pumpEventQueue();
        expect(cubit.state.mangas, const [Manga(id: 'fresh')]);

        // …then the stale one lands last and must be dropped instead of
        // overwriting the newer results and advancing the parameter.
        responses[0].complete(
          Success(
            Pagination(
              data: const [Manga(id: 'stale')],
              page: 5,
              limit: 20,
              total: 40,
            ),
          ),
        );
        await pumpEventQueue();

        expect(cubit.state.mangas, const [Manga(id: 'fresh')]);
        expect(cubit.state.parameter.page, 8);

        await Future.wait([first, second]);
        expect(cubit.state.isLoading, isFalse);
      },
    );

    test(
      'drops a pending next() response when a newer init supersedes it (#123)',
      () async {
        final responses = completeInCallOrder();

        final firstInit = cubit.init();
        await pumpEventQueue();
        responses[0].complete(
          Success(
            Pagination(
              data: const [Manga(id: 'page-one')],
              page: 1,
              limit: 20,
              total: 60,
              hasNextPage: true,
            ),
          ),
        );
        await pumpEventQueue();
        expect(cubit.state.hasNextPage, isTrue);

        final next = cubit.next();
        await pumpEventQueue();
        expect(cubit.state.isPagingNextPage, isTrue);

        final secondInit = cubit.init();
        await pumpEventQueue();

        // next()'s response lands after the newer init started — stale.
        responses[1].complete(
          Success(
            Pagination(
              data: const [Manga(id: 'next-page')],
              page: 2,
              limit: 20,
              total: 60,
            ),
          ),
        );
        await pumpEventQueue();

        expect(cubit.state.mangas, isEmpty);
        expect(cubit.state.isPagingNextPage, isFalse);

        responses[2].complete(
          Success(
            Pagination(
              data: const [Manga(id: 'fresh')],
              page: 1,
              limit: 20,
              total: 40,
            ),
          ),
        );
        await pumpEventQueue();

        expect(cubit.state.mangas, const [Manga(id: 'fresh')]);
        expect(cubit.state.isLoading, isFalse);

        await Future.wait([firstInit, next, secondInit]);
      },
    );

    test(
      "an older init's completion does not clear a newer init's loading state (#123)",
      () async {
        final responses = completeInCallOrder();

        final first = cubit.init();
        await pumpEventQueue();
        final second = cubit.init();
        await pumpEventQueue();
        expect(cubit.state.isLoading, isTrue);

        // The older fetch lands while the newer one is still in flight.
        responses[0].complete(
          Success(
            Pagination(
              data: const [Manga(id: 'stale')],
              page: 5,
              limit: 20,
              total: 40,
            ),
          ),
        );
        await pumpEventQueue();

        expect(cubit.state.isLoading, isTrue);
        expect(cubit.state.mangas, isEmpty);

        responses[1].complete(
          Success(
            Pagination(
              data: const [Manga(id: 'fresh')],
              page: 7,
              limit: 20,
              total: 40,
            ),
          ),
        );
        await pumpEventQueue();

        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.mangas, const [Manga(id: 'fresh')]);

        await Future.wait([first, second]);
      },
    );
  });
}
