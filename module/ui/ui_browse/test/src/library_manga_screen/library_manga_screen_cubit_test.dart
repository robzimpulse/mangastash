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
import 'package:ui_browse/src/library_manga_screen/library_manga_screen_state.dart';
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

  group('LibraryMangaScreenCubit.update (search)', () {
    // Issue #124: copyWith(mangaTitle: mangaTitle ?? this.mangaTitle) can
    // never reset the title to null and closing search only flipped
    // isSearchActive, so reopening filtered by an invisible previous query
    // while the fresh TextEditingController showed an empty box.
    const naruto = Manga(id: 'm-naruto', title: 'Naruto');
    const onePiece = Manga(id: 'm-one-piece', title: 'One Piece');

    test(
      'closing search resets the title filter so reopening shows the whole library',
      () {
        cubit.emit(cubit.state.copyWith(mangas: const [naruto, onePiece]));

        cubit.update(isSearchActive: true, mangaTitle: 'naruto');
        expect(cubit.state.filteredMangas, const [naruto]);

        cubit.update(isSearchActive: false);
        expect(cubit.state.mangaTitle, isNull);
        expect(cubit.state.filteredMangas, const [naruto, onePiece]);

        // Reopening passes only isSearchActive — the fresh field is empty,
        // so the grid must not filter by the previous query.
        cubit.update(isSearchActive: true);
        expect(cubit.state.mangaTitle, isNull);
        expect(cubit.state.filteredMangas, const [naruto, onePiece]);
      },
    );

    test(
      'backspacing the field to empty clears the filter while search stays open',
      () {
        // Review on #159: onChanged('') used to store '' (not null), and
        // contains('') hides null-titled rows while keeping titled ones —
        // two "show everything" gestures disagreed.
        const untitled = Manga(id: 'm-untitled');
        cubit.emit(
          cubit.state.copyWith(mangas: const [naruto, untitled, onePiece]),
        );

        cubit.update(isSearchActive: true, mangaTitle: 'naruto');
        expect(cubit.state.filteredMangas, const [naruto]);

        cubit.update(mangaTitle: '');
        expect(cubit.state.mangaTitle, isNull);
        expect(
          cubit.state.filteredMangas,
          const [naruto, untitled, onePiece],
        );
      },
    );
  });

  // Issue #127: re-tapping "prefetch all" must not re-enqueue mangas that
  // are already sitting in the job queue — the loop skips ids present in
  // state.prefetchedMangaIds.
  group('LibraryMangaScreenCubit.prefetch (#127)', () {
    test('skips mangas already queued in the job queue', () {
      final prefetchMangaUseCase = MockPrefetchMangaUseCase();
      final cubit = LibraryMangaScreenCubit(
        initialState: LibraryMangaScreenState(
          mangas: const [
            Manga(id: 'm-1', source: 'Manga Dex'),
            Manga(id: 'm-2', source: 'Manga Dex'),
          ],
          prefetchedMangaIds: const {'m-1'},
        ),
        getMangaFromUrlUseCase: getMangaFromUrlUseCase,
        addToLibraryUseCase: addToLibraryUseCase,
        listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
        prefetchMangaUseCase: prefetchMangaUseCase,
        listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
        removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
        prefetchChapterUseCase: MockPrefetchChapterUseCase(),
        listenSourcesUseCase: mockListenSourcesUseCase(),
      );
      addTearDown(cubit.close);

      cubit.prefetch(mangas: cubit.state.mangas);

      verify(
        () => prefetchMangaUseCase.prefetchManga(
          mangaId: 'm-2',
          source: any(named: 'source'),
        ),
      ).called(1);
      verifyNever(
        () => prefetchMangaUseCase.prefetchManga(
          mangaId: 'm-1',
          source: any(named: 'source'),
        ),
      );
    });
  });
}
