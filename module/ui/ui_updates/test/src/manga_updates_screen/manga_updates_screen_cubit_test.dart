// Cubit tests for MangaUpdatesScreenCubit (issue #125): the unread stream can
// carry malformed MangaChapter pairs (null manga or null chapter — e.g. a
// history row whose manga was deleted). The cubit must drop them instead of
// passing them through, because a null-returning ListView itemBuilder
// truncates the list at the first malformed row.
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ui_updates/src/manga_updates_screen/manga_updates_screen_cubit.dart';
import 'package:ui_updates/src/manga_updates_screen/manga_updates_screen_state.dart';

import '../../mock/mock.dart';

void main() {
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
}
