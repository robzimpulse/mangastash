// Tests for MangaReaderScreenCubit.recrawl: the built-in MangaDex source has
// no scraping hooks (they throw UnimplementedError by design), so recrawl
// must open the url without touching the source; scraped sources likewise
// just open the url (cached script results are evicted by RecrawlUseCase,
// issue #115).
//
// Run with: fvm flutter test test/src/manga_reader_screen/manga_reader_screen_cubit_test.dart
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ui_browse/src/manga_reader_screen/manga_reader_screen_cubit.dart';
import 'package:ui_browse/src/manga_reader_screen/manga_reader_screen_state.dart';

import '../../mock/mock.dart';

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeBuildContext());
  });

  test('recrawl opens the url for the built-in MangaDex source', () async {
    final recrawlUseCase = MockRecrawlUseCase();
    when(
      () => recrawlUseCase.execute(
        context: any(named: 'context'),
        url: any(named: 'url'),
      ),
    ).thenAnswer((_) async {});

    final cubit = MangaReaderScreenCubit(
      initialState: MangaReaderScreenState(source: MangaDexSourceExternal()),
      getChapterUseCase: MockGetChapterUseCase(),
      updateChapterUseCase: MockUpdateChapterUseCase(),
      listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
      recrawlUseCase: recrawlUseCase,
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      getNeighbourChapterUseCase: MockGetNeighbourChapterUseCase(),
      listenPrefetchChapterConfig: mockListenPrefetchChapterConfig(),
    );
    addTearDown(cubit.close);

    cubit.recrawl(context: _FakeBuildContext(), url: 'https://www.mangadex.org/');
    await pumpEventQueue();

    final verification = verify(
      () => recrawlUseCase.execute(
        context: captureAny(named: 'context'),
        url: captureAny(named: 'url'),
      ),
    );
    verification.called(1);
    expect(verification.captured[1], 'https://www.mangadex.org/');
  });

  test('recrawl opens the url for a scraped source', () async {
    final source = FakeScrapedSourceExternal();
    final recrawlUseCase = MockRecrawlUseCase();
    when(
      () => recrawlUseCase.execute(
        context: any(named: 'context'),
        url: any(named: 'url'),
      ),
    ).thenAnswer((_) async {});

    final cubit = MangaReaderScreenCubit(
      initialState: MangaReaderScreenState(source: source),
      getChapterUseCase: MockGetChapterUseCase(),
      updateChapterUseCase: MockUpdateChapterUseCase(),
      listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
      recrawlUseCase: recrawlUseCase,
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      getNeighbourChapterUseCase: MockGetNeighbourChapterUseCase(),
      listenPrefetchChapterConfig: mockListenPrefetchChapterConfig(),
    );
    addTearDown(cubit.close);

    cubit.recrawl(context: _FakeBuildContext(), url: 'https://asurascans.com/comics/solo-swordmaster-3ec3b16f');
    await pumpEventQueue();

    final verification = verify(
      () => recrawlUseCase.execute(
        context: captureAny(named: 'context'),
        url: captureAny(named: 'url'),
      ),
    );
    verification.called(1);
    expect(verification.captured[1], 'https://asurascans.com/comics/solo-swordmaster-3ec3b16f');
  });
}
