// Tests for LibraryMangaScreenCubit.add: failures must surface through the
// state's addMangaError (invalid URL, unknown source host, use-case Error)
// instead of being silently swallowed, and successful adds must not duplicate
// an already-saved manga.
//
// Run with: fvm flutter test test/src/library_manga_screen/library_manga_screen_cubit_test.dart
import 'package:core_network/core_network.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ui_browse/src/library_manga_screen/library_manga_screen_cubit.dart';
import '../../mock/mock.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(MangaDexSourceExternal());
    registerFallbackValue(const Manga());
  });

  late MockGetMangaFromUrlUseCase getMangaFromUrlUseCase;
  late MockAddToLibraryUseCase addToLibraryUseCase;
  late LibraryMangaScreenCubit cubit;

  setUp(() {
    getMangaFromUrlUseCase = MockGetMangaFromUrlUseCase();
    addToLibraryUseCase = MockAddToLibraryUseCase();
    when(
      () => addToLibraryUseCase.execute(manga: any(named: 'manga')),
    ).thenAnswer((_) async => Success<bool>(true));

    cubit = LibraryMangaScreenCubit(
      getMangaFromUrlUseCase: getMangaFromUrlUseCase,
      addToLibraryUseCase: addToLibraryUseCase,
      listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
      prefetchMangaUseCase: MockPrefetchMangaUseCase(),
      listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
      removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      listenSourcesUseCase: mockListenSourcesUseCase(),
    );
    addTearDown(cubit.close);
  });

  group('LibraryMangaScreenCubit.add', () {
    test('emits addMangaError for an unsupported url', () async {
      cubit.add(url: 'not a url');
      await pumpEventQueue();

      expect(cubit.state.addMangaError, isNotNull);
    });

    test('emits addMangaError for an unknown source host', () async {
      cubit.add(url: 'https://example.com/manga/some-manga');
      await pumpEventQueue();

      expect(cubit.state.addMangaError, isNotNull);
    });

    test('emits addMangaError with the error of the use case', () async {
      final failure = Exception('network failed');
      when(
        () => getMangaFromUrlUseCase.execute(
          source: any(named: 'source'),
          url: any(named: 'url'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer((_) async => Error<Manga>(failure));

      cubit.add(url: 'https://asurascans.com/comics/solo-swordmaster-3ec3b16f');
      await pumpEventQueue();

      expect(cubit.state.addMangaError, same(failure));
    });

    test('does not re-add a manga already in the library', () async {
      when(
        () => getMangaFromUrlUseCase.execute(
          source: any(named: 'source'),
          url: any(named: 'url'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer((_) async => Success<Manga>(const Manga(id: 'm-1')));

      cubit.emit(
        cubit.state.copyWith(mangas: const [Manga(id: 'm-1')]),
      );
      cubit.add(url: 'https://asurascans.com/comics/solo-swordmaster-3ec3b16f');
      await pumpEventQueue();

      verifyNever(
        () => addToLibraryUseCase.execute(manga: any(named: 'manga')),
      );
      expect(cubit.state.addMangaError, isNull);
    });

    test('adds a new manga to the library without an error', () async {
      when(
        () => getMangaFromUrlUseCase.execute(
          source: any(named: 'source'),
          url: any(named: 'url'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer((_) async => Success<Manga>(const Manga(id: 'm-2')));

      cubit.add(url: 'https://asurascans.com/comics/solo-swordmaster-3ec3b16f');
      await pumpEventQueue();

      verify(
        () => addToLibraryUseCase.execute(manga: const Manga(id: 'm-2')),
      ).called(1);
      expect(cubit.state.addMangaError, isNull);
    });

    test('clears a previous error when the next add succeeds', () async {
      cubit.add(url: 'not a url');
      await pumpEventQueue();
      expect(cubit.state.addMangaError, isNotNull);

      when(
        () => getMangaFromUrlUseCase.execute(
          source: any(named: 'source'),
          url: any(named: 'url'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer((_) async => Success<Manga>(const Manga(id: 'm-2')));

      cubit.add(url: 'https://asurascans.com/comics/solo-swordmaster-3ec3b16f');
      await pumpEventQueue();

      expect(cubit.state.addMangaError, isNull);
    });

    test('clears a previous error when the manga is already saved', () async {
      cubit.add(url: 'not a url');
      await pumpEventQueue();
      expect(cubit.state.addMangaError, isNotNull);

      when(
        () => getMangaFromUrlUseCase.execute(
          source: any(named: 'source'),
          url: any(named: 'url'),
          useCache: any(named: 'useCache'),
        ),
      ).thenAnswer((_) async => Success<Manga>(const Manga(id: 'm-1')));

      cubit.emit(
        cubit.state.copyWith(mangas: const [Manga(id: 'm-1')]),
      );
      cubit.add(url: 'https://asurascans.com/comics/solo-swordmaster-3ec3b16f');
      await pumpEventQueue();

      verifyNever(
        () => addToLibraryUseCase.execute(manga: any(named: 'manga')),
      );
      expect(cubit.state.addMangaError, isNull);
    });
  });
}
