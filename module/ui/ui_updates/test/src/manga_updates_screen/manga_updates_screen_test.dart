// Widget tests for MangaUpdatesScreen (issue #125): a null from a
// NullableIndexedWidgetBuilder signals end-of-list to SliverChildBuilder
// delegates, so a malformed entry in state hides every row after it. Even
// though the cubit now filters malformed pairs (see the cubit tests), the
// screen itself must degrade to a blank row instead of truncating — this test
// injects a malformed entry straight through initialState to pin that.
//
// Run with: fvm flutter test test/src/manga_updates_screen/manga_updates_screen_test.dart
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';
import 'package:ui_updates/src/manga_updates_screen/manga_updates_screen.dart';
import 'package:ui_updates/src/manga_updates_screen/manga_updates_screen_cubit.dart';

import '../../mock/mock.dart';

/// Pumps [frames] of 200ms each. ScaffoldScreen contains an always-animating
/// shimmer, so pumpAndSettle never settles (see CLAUDE.md known blockers).
Future<void> pumpFrames(WidgetTester tester, [int frames = 6]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  testWidgets('renders rows after a malformed entry instead of truncating', (
    tester,
  ) async {
    final good1 = seedMangaChapter(mangaId: 'm-1', chapterId: 'c-1');
    final good2 = seedMangaChapter(mangaId: 'm-2', chapterId: 'c-2');
    final cubit = MangaUpdatesScreenCubit(
      listenUnreadHistoryUseCase: mockListenUnreadHistoryUseCase(),
      listenPrefetchUseCase: mockListenPrefetchUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
    );
    // Inject the malformed entry POST-construction: the constructor
    // sanitizes initialState (review on #158), so only a raw copyWith
    // gets a malformed pair past the filter and into the builder —
    // reverting the builder fallback to `return null` must fail this
    // test, not pass vacuously.
    cubit.emit(
      cubit.state.copyWith(
        updates: [
          good1,
          MangaChapter(manga: null, chapter: seedChapter(id: 'c-x')),
          good2,
        ],
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: MangaUpdatesScreen(imagesCacheManager: MockImagesCacheManager()),
        ),
      ),
    );
    await pumpFrames(tester);

    expect(find.byType(ChapterTileWidget), findsNWidgets(2));
    expect(find.text('Empty Data'), findsNothing);
  });

  testWidgets('shows the empty state when updates is empty', (tester) async {
    final cubit = MangaUpdatesScreenCubit(
      listenUnreadHistoryUseCase: mockListenUnreadHistoryUseCase(),
      listenPrefetchUseCase: mockListenPrefetchUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: MangaUpdatesScreen(imagesCacheManager: MockImagesCacheManager()),
        ),
      ),
    );
    await pumpFrames(tester);

    expect(find.text('Empty Data'), findsOneWidget);
    expect(find.byType(ChapterTileWidget), findsNothing);
  });
}
