// Widget tests for MangaDetailScreen's download entry points (issue #119):
// the download popup menu, the manga long-press menu and the per-chapter
// long-press must all reach the prefetch pipeline — no "under construction"
// banner and no silent no-op. Cubit behavior is covered in
// manga_detail_screen_cubit_test.dart; this file verifies the screen wiring
// (which menu item reaches which cubit method, and which snackbar appears).
//
// Run with: fvm flutter test test/src/manga_detail_screen/manga_detail_screen_test.dart
import 'package:core_analytics/core_analytics.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'package:ui_browse/src/manga_detail_screen/manga_detail_screen.dart';
import 'package:ui_browse/src/manga_detail_screen/manga_detail_screen_cubit.dart';
import 'package:ui_browse/src/manga_detail_screen/manga_detail_screen_state.dart';
import 'package:ui_common/ui_common.dart';

import '../../mock/mock.dart';

class _NullCacheManager extends Mock implements ImagesCacheManager {}

class _MockLogBox extends Mock implements LogBox {}

/// Tall enough that the app bar (expandedHeight = 40% of the viewport height)
/// still leaves the chapter list's action row inside the visible area; the
/// download menu button is otherwise below the fold and cannot be hit-tested.
const Size _viewport = Size(800, 2000);

/// Pumps [frames] of 200ms each. ScaffoldScreen contains an always-animating
/// shimmer, so pumpAndSettle never settles (see CLAUDE.md known blockers).
Future<void> pumpFrames(WidgetTester tester, [int frames = 6]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  late MockGetAllChapterUseCase getAllChapterUseCase;
  late MockPrefetchChapterUseCase prefetchChapterUseCase;
  late _NullCacheManager imagesCacheManager;
  late _MockLogBox logBox;
  late MangaDetailScreenCubit cubit;

  const manga = Manga(id: 'm-1', source: 'Manga Dex', title: 'Solo Leveling');
  const chapters = [
    Chapter(id: 'a', chapter: '1'),
    Chapter(id: 'b', chapter: '2'),
  ];

  setUpAll(() {
    registerFallbackValue(MangaDexSourceExternal());
  });

  setUp(() {
    getAllChapterUseCase = MockGetAllChapterUseCase();
    prefetchChapterUseCase = MockPrefetchChapterUseCase();
    imagesCacheManager = _NullCacheManager();
    logBox = _MockLogBox();

    // CachedNetworkImage reaches the cache manager before the network. A bare
    // mock would throw MissingStubError from inside the image loader; failing
    // the fetch instead lets the widgets fall back to their errorWidget.
    when(
      () => imagesCacheManager.getSingleFile(
        any(),
        key: any(named: 'key'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer((_) => Future.error(Exception('no cache in widget tests')));

    when(
      () => getAllChapterUseCase.execute(
        source: any(named: 'source'),
        mangaId: any(named: 'mangaId'),
        parameter: any(named: 'parameter'),
      ),
    ).thenAnswer((_) async => chapters);
  });

  MangaDetailScreenCubit buildCubit({MangaDetailScreenState? initialState}) {
    final listenDownloadedChapterUseCase = MockListenDownloadedChapterUseCase();
    when(
      () => listenDownloadedChapterUseCase.execute(
        mangaId: any(named: 'mangaId'),
      ),
    ).thenAnswer((_) => const Stream.empty());
    final result = MangaDetailScreenCubit(
      initialState:
          initialState ??
          const MangaDetailScreenState(
            manga: manga,
            chapters: chapters,
            totalChapter: 2,
            similarManga: [Manga(id: 's-1', source: 'Manga Dex')],
          ),
      getMangaUseCase: MockGetMangaUseCase(),
      searchMangaUseCase: MockSearchMangaUseCase(),
      searchChapterUseCase: MockSearchChapterUseCase(),
      addToLibraryUseCase: MockAddToLibraryUseCase(),
      removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
      listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
      listenPrefetchUseCase: mockListenPrefetchUseCase(),
      prefetchChapterUseCase: prefetchChapterUseCase,
      listenReadHistoryUseCase: mockListenReadHistoryUseCase(),
      listenSearchParameterUseCase: mockListenSearchParameterUseCase(),
      getAllChapterUseCase: getAllChapterUseCase,
      recrawlUseCase: MockRecrawlUseCase(),
      listenDownloadedChapterUseCase: listenDownloadedChapterUseCase,
    );
    // The constructor registers four stream subscriptions plus, when the state
    // carries a mangaId, the downloaded-chapter listener; close() cancels
    // them, so an unclosed cubit leaks every one.
    addTearDown(result.close);
    return result;
  }

  Future<void> pumpScreen(WidgetTester tester, {MangaMenu? onMangaMenu}) async {
    tester.view.physicalSize = _viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        // The similar-manga grid sizes itself off ResponsiveBreakpoints; the
        // app installs the same breakpoints in AppsScreen.builder.
        builder:
            (context, child) => ResponsiveBreakpoints.builder(
              breakpoints: const [
                Breakpoint(start: 0, end: 450, name: MOBILE),
                Breakpoint(start: 451, end: 800, name: TABLET),
                Breakpoint(start: 801, end: 1280, name: DESKTOP),
                Breakpoint(start: 1281, end: double.infinity, name: '4K'),
              ],
              child: child ?? const SizedBox.shrink(),
            ),
        home: BlocProvider.value(
          value: cubit,
          child: MangaDetailScreen(
            imagesCacheManager: imagesCacheManager,
            logBox: logBox,
            onMangaMenu: (manga, isOnLibrary) async => onMangaMenu,
          ),
        ),
      ),
    );
    await pumpFrames(tester);
  }

  /// Opens the download popup menu and picks [option] ('Unread' or 'All').
  Future<void> tapDownloadOption(WidgetTester tester, String option) async {
    await tester.tap(find.byIcon(Icons.download));
    await pumpFrames(tester);
    await tester.tap(find.text(option));
    await pumpFrames(tester);
  }

  /// Chapter ids passed to prefetchChapter, in call order.
  List<String?> enqueuedChapterIds() {
    final verification = verify(
      () => prefetchChapterUseCase.prefetchChapter(
        mangaId: any(named: 'mangaId'),
        source: any(named: 'source'),
        chapterId: captureAny(named: 'chapterId'),
      ),
    );
    verification.called(greaterThan(0));
    return verification.captured.cast<String?>();
  }

  group('download menu (#119)', () {
    // Spec §4: "Chapter-list fetch fails -> abort + snackbar, enqueue
    // nothing". download() has no catch, so without a handler here the error
    // escapes through the void async caller and the user sees nothing at all.
    testWidgets(
      'a failed chapter-list fetch reports itself and queues nothing',
      (tester) async {
        when(
          () => getAllChapterUseCase.execute(
            source: any(named: 'source'),
            mangaId: any(named: 'mangaId'),
            parameter: any(named: 'parameter'),
          ),
        ).thenThrow(Exception('chapter fetch failed'));
        cubit = buildCubit();
        await pumpScreen(tester);

        await tapDownloadOption(tester, 'All');

        verifyNever(
          () => prefetchChapterUseCase.prefetchChapter(
            mangaId: any(named: 'mangaId'),
            source: any(named: 'source'),
            chapterId: any(named: 'chapterId'),
          ),
        );
        // "Exception: " is stripped so the snackbar reads like the sibling
        // "Failed to add manga: ..." wording in library_manga_screen.
        expect(
          find.text('Failed to load chapters: chapter fetch failed'),
          findsOneWidget,
        );
        // download()'s finally block resets the flag on the throw, so a
        // failed fetch must not leave the run stuck.
        expect(cubit.state.isPrefetchingAll, isFalse);
      },
    );

    testWidgets(
      'All enqueues every chapter and drops the construction banner',
      (tester) async {
        cubit = buildCubit();
        await pumpScreen(tester);

        await tapDownloadOption(tester, 'All');

        expect(enqueuedChapterIds(), ['a', 'b']);
        expect(find.textContaining('Under Construction'), findsNothing);
      },
    );

    // Routing, not just queueing: "Unread" must skip the chapters the user
    // already read, or the option is indistinguishable from "All".
    testWidgets('Unread skips the chapters with a read history', (
      tester,
    ) async {
      cubit = buildCubit(
        initialState: const MangaDetailScreenState(
          manga: manga,
          chapters: chapters,
          totalChapter: 2,
          histories: {'a': Chapter(id: 'a', lastReadAt: null)},
        ),
      );
      await pumpScreen(tester);

      await tapDownloadOption(tester, 'Unread');

      expect(enqueuedChapterIds(), ['b']);
    });

    testWidgets('an empty target explains itself instead of doing nothing', (
      tester,
    ) async {
      cubit = buildCubit(
        initialState: const MangaDetailScreenState(
          manga: manga,
          chapters: chapters,
          totalChapter: 2,
          prefetchedChapterIds: {'a', 'b'},
        ),
      );
      await pumpScreen(tester);

      await tapDownloadOption(tester, 'All');

      verifyNever(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          chapterId: any(named: 'chapterId'),
        ),
      );
      expect(find.text('Nothing to download'), findsOneWidget);
    });

    // download() returns 0 both for "nothing left to queue" and for "a run is
    // already in flight". Only the first is worth a snackbar — a download is
    // under way in the second, so saying so would be a lie.
    testWidgets('a run already in flight shows no empty-target snackbar', (
      tester,
    ) async {
      cubit = buildCubit(
        initialState: const MangaDetailScreenState(
          manga: manga,
          chapters: chapters,
          totalChapter: 2,
          isPrefetchingAll: true,
        ),
      );
      await pumpScreen(tester);

      await tapDownloadOption(tester, 'All');

      verifyNever(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          chapterId: any(named: 'chapterId'),
        ),
      );
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('manga long-press menu (#119)', () {
    Future<void> longPressSimilarManga(WidgetTester tester) async {
      await tester.tap(find.text('Similar'));
      await pumpFrames(tester);
      await tester.longPress(find.text('Similar Manga'));
      await pumpFrames(tester);
    }

    testWidgets('Download enqueues every chapter', (tester) async {
      cubit = buildCubit(
        initialState: const MangaDetailScreenState(
          manga: manga,
          similarManga: [
            Manga(id: 's-1', source: 'Manga Dex', title: 'Similar Manga'),
          ],
        ),
      );
      await pumpScreen(tester, onMangaMenu: MangaMenu.download);

      await longPressSimilarManga(tester);

      expect(enqueuedChapterIds(), ['a', 'b']);
      expect(find.textContaining('Under Construction'), findsNothing);
      // download() stages the queued ids into state synchronously, which is
      // what keeps a double tap from re-enqueueing (#119).
      expect(cubit.state.prefetchedChapterIds, {'a', 'b'});
    });

    // The menu routes through the same handler as the header popup, so it
    // gets the same empty-target feedback instead of silently doing nothing.
    testWidgets('Download explains an empty target', (tester) async {
      cubit = buildCubit(
        initialState: const MangaDetailScreenState(
          manga: manga,
          prefetchedChapterIds: {'a', 'b'},
          similarManga: [
            Manga(id: 's-1', source: 'Manga Dex', title: 'Similar Manga'),
          ],
        ),
      );
      await pumpScreen(tester, onMangaMenu: MangaMenu.download);

      await longPressSimilarManga(tester);

      verifyNever(
        () => prefetchChapterUseCase.prefetchChapter(
          mangaId: any(named: 'mangaId'),
          source: any(named: 'source'),
          chapterId: any(named: 'chapterId'),
        ),
      );
      expect(find.text('Nothing to download'), findsOneWidget);
    });

    // prefetch() is the other branch of the same menu. It reads the queued ids
    // instead of writing them, so the assertion above separates it from
    // download().
    testWidgets('Prefetch enqueues every chapter', (tester) async {
      cubit = buildCubit(
        initialState: const MangaDetailScreenState(
          manga: manga,
          similarManga: [
            Manga(id: 's-1', source: 'Manga Dex', title: 'Similar Manga'),
          ],
        ),
      );
      await pumpScreen(tester, onMangaMenu: MangaMenu.prefetch);

      await longPressSimilarManga(tester);

      expect(enqueuedChapterIds(), ['a', 'b']);
      expect(cubit.state.prefetchedChapterIds, isEmpty);
    });
  });

  group('chapter long-press (#119)', () {
    testWidgets('enqueues that chapter only', (tester) async {
      cubit = buildCubit();
      await pumpScreen(tester);

      await tester.longPress(find.text('Chapter 2'));
      await pumpFrames(tester);

      expect(enqueuedChapterIds(), ['b']);
    });

    // The tile already renders a progress spinner for a queued chapter, so a
    // repeat long-press has visible feedback — but it must not enqueue twice.
    testWidgets('a queued chapter is not enqueued twice', (tester) async {
      cubit = buildCubit();
      await pumpScreen(tester);

      await tester.longPress(find.text('Chapter 2'));
      await pumpFrames(tester);
      await tester.longPress(find.text('Chapter 2'));
      await pumpFrames(tester);

      expect(enqueuedChapterIds(), ['b']);
    });
  });
}
