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

    // Review on #175: prefetchedMangaIds only refreshes via the async
    // mangaIdsStream hop, so two taps before the stream emits read the
    // same state and both enqueue everything (JobDao.add is a plain
    // insert). The enqueued ids must land in state synchronously so the
    // second tap already sees them.
    test('rapid double-taps do not duplicate enqueues (review on #175)', () {
      final prefetchMangaUseCase = MockPrefetchMangaUseCase();
      final prefetchChapterUseCase = MockPrefetchChapterUseCase();
      final cubit = LibraryMangaScreenCubit(
        initialState: const LibraryMangaScreenState(
          mangas: [Manga(id: 'm-1', source: 'Manga Dex')],
        ),
        getMangaFromUrlUseCase: getMangaFromUrlUseCase,
        addToLibraryUseCase: addToLibraryUseCase,
        listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
        prefetchMangaUseCase: prefetchMangaUseCase,
        // mangaIdsStream is stubbed to an empty stream — it never emits,
        // so the state set can only update through prefetch itself.
        listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
        removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
        prefetchChapterUseCase: prefetchChapterUseCase,
        listenSourcesUseCase: mockListenSourcesUseCase(),
      );
      addTearDown(cubit.close);

      cubit.prefetch(mangas: cubit.state.mangas);
      cubit.prefetch(mangas: cubit.state.mangas);

      verify(
        () => prefetchMangaUseCase.prefetchManga(
          mangaId: 'm-1',
          source: any(named: 'source'),
        ),
      ).called(1);
      verify(
        () => prefetchChapterUseCase.prefetchChapters(
          mangaId: 'm-1',
          source: any(named: 'source'),
        ),
      ).called(1);
    });
  });

  // Issue #119: the Download menu item used to be an inert stub. It now
  // enqueues the same two jobs as prefetch() — the manga record and its full
  // chapter list — resolving the source by name like prefetch() does, because
  // Manga.source holds the source *name*, not the SourceExternal the use cases
  // take. Unlike prefetch() it takes one already-resolved manga instead of a
  // list, but it keeps both of prefetch()'s guards: a manga already in the job
  // queue is skipped, and the enqueued id is staged into state synchronously
  // so a repeat tap reads the fresh set — see "a double tap enqueues once".
  group('LibraryMangaScreenCubit.download (#119)', () {
    late MockPrefetchMangaUseCase prefetchMangaUseCase;
    late MockPrefetchChapterUseCase prefetchChapterUseCase;
    late LibraryMangaScreenCubit downloadCubit;

    setUp(() {
      prefetchMangaUseCase = MockPrefetchMangaUseCase();
      prefetchChapterUseCase = MockPrefetchChapterUseCase();
      downloadCubit = LibraryMangaScreenCubit(
        getMangaFromUrlUseCase: MockGetMangaFromUrlUseCase(),
        addToLibraryUseCase: MockAddToLibraryUseCase(),
        listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
        prefetchMangaUseCase: prefetchMangaUseCase,
        listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
        removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
        prefetchChapterUseCase: prefetchChapterUseCase,
        listenSourcesUseCase: mockListenSourcesUseCase(),
      );
      addTearDown(downloadCubit.close);
    });

    test('enqueues the manga and its chapters with the resolved source', () {
      downloadCubit.download(
        manga: const Manga(id: 'm-1', source: 'Manga Dex'),
      );

      final mangaVerification = verify(
        () => prefetchMangaUseCase.prefetchManga(
          mangaId: 'm-1',
          source: captureAny(named: 'source'),
        ),
      );
      mangaVerification.called(1);
      expect(
        mangaVerification.captured[0],
        isA<MangaDexSourceExternal>(),
      );
      final chapterVerification = verify(
        () => prefetchChapterUseCase.prefetchChapters(
          mangaId: 'm-1',
          source: captureAny(named: 'source'),
        ),
      );
      chapterVerification.called(1);
      expect(
        chapterVerification.captured[0],
        isA<MangaDexSourceExternal>(),
      );
    });

    // Enqueues are all-or-nothing per manga: an unknown source name resolves to
    // null (the job would carry no source to fetch from) and a null id cannot
    // key the job, so neither may enqueue. The valid download first proves the
    // path is live — otherwise these count as 0 and pass for the wrong reason.
    test('enqueues nothing for an unknown source or a missing id', () {
      downloadCubit.download(
        manga: const Manga(id: 'm-1', source: 'Manga Dex'),
      );
      downloadCubit.download(
        manga: const Manga(id: 'm-2', source: 'Removed Source'),
      );
      downloadCubit.download(manga: const Manga(source: 'Manga Dex'));

      // Only the first manga's two jobs — m-2 and the id-less manga skipped.
      final mangaVerification = verify(
        () => prefetchMangaUseCase.prefetchManga(
          mangaId: captureAny(named: 'mangaId'),
          source: any(named: 'source'),
        ),
      );
      mangaVerification.called(1);
      expect(mangaVerification.captured, ['m-1']);
      final chapterVerification = verify(
        () => prefetchChapterUseCase.prefetchChapters(
          mangaId: captureAny(named: 'mangaId'),
          source: any(named: 'source'),
        ),
      );
      chapterVerification.called(1);
      expect(chapterVerification.captured, ['m-1']);
    });

    // job_tables carries no unique key, so a duplicate insert is accepted and
    // JobManager runs every row: a second prefetchChapters re-fetches the whole
    // chapter list and each prefetchChapter re-downloads every image to disk.
    // mangaIdsStream is stubbed to an empty stream — it never emits, so the
    // queued set can only come from download's own synchronous emit. Without
    // that staging the second tap reads a stale set and duplicates the work.
    test('a double tap enqueues once', () {
      const manga = Manga(id: 'm-1', source: 'Manga Dex');
      downloadCubit.download(manga: manga);
      downloadCubit.download(manga: manga);

      verify(
        () => prefetchMangaUseCase.prefetchManga(
          mangaId: 'm-1',
          source: any(named: 'source'),
        ),
      ).called(1);
      verify(
        () => prefetchChapterUseCase.prefetchChapters(
          mangaId: 'm-1',
          source: any(named: 'source'),
        ),
      ).called(1);
      expect(downloadCubit.state.prefetchedMangaIds, {'m-1'});
    });
  });
}
