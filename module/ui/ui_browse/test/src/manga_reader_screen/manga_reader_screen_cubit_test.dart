// Tests for MangaReaderScreenCubit.recrawl: the built-in MangaDex source has
// no scraping use cases (getters throw UnimplementedError by design), so
// recrawl must pass an empty scripts list instead of crashing.
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

  test('recrawl passes no scripts for the built-in MangaDex source', () async {
    final recrawlUseCase = MockRecrawlUseCase();
    when(
      () => recrawlUseCase.execute(
        context: any(named: 'context'),
        url: any(named: 'url'),
        scripts: any(named: 'scripts'),
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
        scripts: captureAny(named: 'scripts'),
      ),
    );
    verification.called(1);
    expect(verification.captured[2] as List<String>, isEmpty);
  });
}
