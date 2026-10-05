// Tests for MangaGridWidgetCubit.recrawl: the built-in MangaDex source has
// no scraping use cases (getters throw UnimplementedError by design), so
// recrawl must pass an empty scripts list instead of crashing.
//
// Run with: fvm flutter test test/src/widget/manga_grid_widget/manga_grid_widget_cubit_test.dart
import 'dart:async';

import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ui_browse/src/widget/manga_grid_widget/manga_grid_widget_cubit.dart';
import 'package:ui_browse/src/widget/manga_grid_widget/manga_grid_widget_state.dart';

import '../../../mock/mock.dart';

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeBuildContext());
    registerFallbackValue(const Manga());
    registerFallbackValue(MangaDexSourceExternal());
    registerFallbackValue(
      const SourceSearchMangaParameter(source: '', parameter: SearchMangaParameter()),
    );
  });

  test('recrawl passes no scripts for the built-in MangaDex source', () async {
    final recrawlUseCase = MockRecrawlUseCase();
    final searchMangaUseCase = MockSearchMangaUseCase();
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

    final cubit = MangaGridWidgetCubit(
      initialState: MangaGridWidgetState(source: MangaDexSourceExternal()),
      parentCubit: mockSearchMangaScreenCubit(),
      listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
      listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
      listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
      searchMangaUseCase: searchMangaUseCase,
      recrawlUseCase: recrawlUseCase,
      prefetchMangaUseCase: MockPrefetchMangaUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
      addToLibraryUseCase: MockAddToLibraryUseCase(),
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

    final cubit = MangaGridWidgetCubit(
      initialState: MangaGridWidgetState(source: FakeScrapedSourceExternal()),
      parentCubit: mockSearchMangaScreenCubit(),
      listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
      listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
      listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
      searchMangaUseCase: searchMangaUseCase,
      recrawlUseCase: recrawlUseCase,
      prefetchMangaUseCase: MockPrefetchMangaUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
      addToLibraryUseCase: MockAddToLibraryUseCase(),
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

  group('MangaGridWidgetCubit.init/next (issues #122 & #123)', () {
    late MockSearchMangaUseCase searchMangaUseCase;
    late MangaGridWidgetCubit cubit;

    setUp(() {
      searchMangaUseCase = MockSearchMangaUseCase();
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

      cubit = MangaGridWidgetCubit(
        initialState: MangaGridWidgetState(source: MangaDexSourceExternal()),
        parentCubit: mockSearchMangaScreenCubit(),
        listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
        listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
        listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
        searchMangaUseCase: searchMangaUseCase,
        recrawlUseCase: MockRecrawlUseCase(),
        prefetchMangaUseCase: MockPrefetchMangaUseCase(),
        prefetchChapterUseCase: MockPrefetchChapterUseCase(),
        removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
        addToLibraryUseCase: MockAddToLibraryUseCase(),
      );
      addTearDown(cubit.close);
    });

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

        final first = cubit.init();
        await pumpEventQueue();
        final second = cubit.init();
        await pumpEventQueue();
        expect(responses, hasLength(2));

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
  });

  // Issue #127: same double-tap race as the browse screen — the favorite
  // toggle must no-op while the same manga's toggle is already in flight.
  group('addToLibrary in-flight guard (#127)', () {
    late MockAddToLibraryUseCase addToLibraryUseCase;
    late MangaGridWidgetCubit guardCubit;

    setUp(() {
      addToLibraryUseCase = MockAddToLibraryUseCase();
      guardCubit = MangaGridWidgetCubit(
        initialState: MangaGridWidgetState(source: MangaDexSourceExternal()),
        parentCubit: mockSearchMangaScreenCubit(),
        listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
        listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
        listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
        searchMangaUseCase: MockSearchMangaUseCase(),
        recrawlUseCase: MockRecrawlUseCase(),
        prefetchMangaUseCase: MockPrefetchMangaUseCase(),
        prefetchChapterUseCase: MockPrefetchChapterUseCase(),
        removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
        addToLibraryUseCase: addToLibraryUseCase,
      );
      addTearDown(guardCubit.close);
    });

    test('a second tap while the first is pending is ignored', () async {
      final gate = Completer<Result<bool>>();
      when(
        () => addToLibraryUseCase.execute(manga: any(named: 'manga')),
      ).thenAnswer((_) => gate.future);

      const manga = Manga(id: 'm-1', source: 'Manga Dex');
      final first = guardCubit.addToLibrary(manga: manga);
      await pumpEventQueue();
      final second = guardCubit.addToLibrary(manga: manga);
      await pumpEventQueue();

      verify(
        () => addToLibraryUseCase.execute(manga: any(named: 'manga')),
      ).called(1);

      gate.complete(Success<bool>(true));
      await Future.wait([first, second]);
    });
  });
}
