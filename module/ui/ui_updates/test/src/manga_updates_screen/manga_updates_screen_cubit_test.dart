// Cubit tests for MangaUpdatesScreenCubit (issue #125): the unread stream can
// carry malformed MangaChapter pairs (null manga or null chapter — e.g. a
// history row whose manga was deleted). The cubit must drop them instead of
// passing them through, because a null-returning ListView itemBuilder
// truncates the list at the first malformed row.
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ui_updates/src/manga_updates_screen/manga_updates_screen_cubit.dart';
import 'package:ui_updates/src/manga_updates_screen/manga_updates_screen_state.dart';

import '../../mock/mock.dart';

void main() {
  setUpAll(() {
    // PrefetchChapterUseCase.prefetchChapter takes a SourceExternal.
    registerFallbackValue(MangaDexSourceExternal());
  });

  test(
    'drops malformed entries (null manga or null chapter) from the stream',
    () async {
      final good1 = seedMangaChapter(mangaId: 'm-1', chapterId: 'c-1');
      final good2 = seedMangaChapter(mangaId: 'm-2', chapterId: 'c-2');
      final listenUnread = MockListenUnreadHistoryUseCase();
      when(() => listenUnread.unreadHistoryStream).thenAnswer(
        (_) => Stream.value([
          good1,
          MangaChapter(manga: null, chapter: seedChapter(id: 'c-x')),
          good2,
          MangaChapter(manga: seedManga(id: 'm-y'), chapter: null),
        ]),
      );

      final cubit = MangaUpdatesScreenCubit(
        listenUnreadHistoryUseCase: listenUnread,
        listenPrefetchUseCase: mockListenPrefetchUseCase(),
        prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      );
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state.updates, [good1, good2]);
    },
  );

  test(
    'an all-malformed stream leaves updates empty so the screen shows its empty state',
    () async {
      final listenUnread = MockListenUnreadHistoryUseCase();
      when(() => listenUnread.unreadHistoryStream).thenAnswer(
        (_) => Stream.value([
          MangaChapter(manga: null, chapter: seedChapter(id: 'c-x')),
          MangaChapter(manga: seedManga(id: 'm-y'), chapter: null),
        ]),
      );

      final cubit = MangaUpdatesScreenCubit(
        listenUnreadHistoryUseCase: listenUnread,
        listenPrefetchUseCase: mockListenPrefetchUseCase(),
        prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      );
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state.updates, isEmpty);
    },
  );

  test(
    'a malformed initialState is sanitized before it becomes the state',
    () async {
      // Review follow-up on #158: the stream filter must also cover
      // constructor-provided initial states, or an all-malformed
      // initialState renders blank rows instead of the Empty Data state.
      final cubit = MangaUpdatesScreenCubit(
        initialState: MangaUpdatesScreenState(
          updates: [
            MangaChapter(manga: null, chapter: seedChapter(id: 'c-x')),
            MangaChapter(manga: seedManga(id: 'm-y'), chapter: null),
          ],
        ),
        listenUnreadHistoryUseCase: mockListenUnreadHistoryUseCase(),
        listenPrefetchUseCase: mockListenPrefetchUseCase(),
        prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      );
      addTearDown(cubit.close);

      await pumpEventQueue();

      expect(cubit.state.updates, isEmpty);
    },
  );

  // Issue #127: re-tapping "prefetch all" must not re-enqueue chapters that
  // are already sitting in the job queue — the loop skips ids present in
  // state.prefetchedChapterIds.
  test('prefetch skips chapters already queued in the job queue (#127)', () async {
    final queued = MangaChapter(
      manga: Manga(id: 'm-1', source: 'Manga Dex'),
      chapter: seedChapter(id: 'c-1'),
    );
    final fresh = MangaChapter(
      manga: Manga(id: 'm-2', source: 'Manga Dex'),
      chapter: seedChapter(id: 'c-2'),
    );
    final listenUnread = MockListenUnreadHistoryUseCase();
    when(
      () => listenUnread.unreadHistoryStream,
    ).thenAnswer((_) => Stream.value([queued, fresh]));

    final prefetchChapterUseCase = MockPrefetchChapterUseCase();
    final cubit = MangaUpdatesScreenCubit(
      initialState: const MangaUpdatesScreenState(prefetchedChapterIds: {'c-1'}),
      listenUnreadHistoryUseCase: listenUnread,
      listenPrefetchUseCase: mockListenPrefetchUseCase(),
      prefetchChapterUseCase: prefetchChapterUseCase,
    );
    addTearDown(cubit.close);
    await pumpEventQueue();
    expect(cubit.state.updates, hasLength(2));

    cubit.prefetch();

    final verification = verify(
      () => prefetchChapterUseCase.prefetchChapter(
        mangaId: any(named: 'mangaId'),
        source: any(named: 'source'),
        chapterId: captureAny(named: 'chapterId'),
      ),
    );
    verification.called(1);
    expect(verification.captured, ['c-2']);
  });

  // Review on #175: prefetchedChapterIds only refreshes via the async
  // chapterIdsStream hop, so two taps before the stream emits read the
  // same state and both enqueue everything (JobDao.add is a plain
  // insert). The enqueued ids must land in state synchronously so the
  // second tap already sees them.
  test('rapid double-taps do not duplicate enqueues (review on #175)', () async {
    final update = MangaChapter(
      manga: const Manga(id: 'm-1', source: 'Manga Dex'),
      chapter: seedChapter(id: 'c-1'),
    );
    final listenUnread = MockListenUnreadHistoryUseCase();
    when(
      () => listenUnread.unreadHistoryStream,
    ).thenAnswer((_) => Stream.value([update]));

    final prefetchChapterUseCase = MockPrefetchChapterUseCase();
    final cubit = MangaUpdatesScreenCubit(
      listenUnreadHistoryUseCase: listenUnread,
      // chapterIdsStream is stubbed to an empty stream — it never emits,
      // so the state set can only update through prefetch itself.
      listenPrefetchUseCase: mockListenPrefetchUseCase(),
      prefetchChapterUseCase: prefetchChapterUseCase,
    );
    addTearDown(cubit.close);
    await pumpEventQueue();
    expect(cubit.state.updates, hasLength(1));

    cubit.prefetch();
    cubit.prefetch();

    final verification = verify(
      () => prefetchChapterUseCase.prefetchChapter(
        mangaId: any(named: 'mangaId'),
        source: any(named: 'source'),
        chapterId: captureAny(named: 'chapterId'),
      ),
    );
    verification.called(1);
    expect(verification.captured, ['c-1']);
  });
}
