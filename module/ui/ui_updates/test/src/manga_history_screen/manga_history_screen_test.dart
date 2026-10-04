// Widget tests for MangaHistoryScreen (issue #125): a null from a
// NullableIndexedWidgetBuilder signals end-of-list to SliverChildBuilder
// delegates, so a malformed entry in state hides every row after it. Even
// though the cubit now filters malformed pairs (see the cubit tests), the
// screen itself must degrade to a blank row instead of truncating — this test
// injects a malformed entry straight through initialState to pin that.
//
// Run with: fvm flutter test test/src/manga_history_screen/manga_history_screen_test.dart
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';
import 'package:ui_updates/src/manga_history_screen/manga_history_screen.dart';
import 'package:ui_updates/src/manga_history_screen/manga_history_screen_cubit.dart';
import 'package:ui_updates/src/manga_history_screen/manga_history_screen_state.dart';

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
    final cubit = MangaHistoryScreenCubit(
      initialState: MangaHistoryScreenState(
        histories: [
          good1,
          MangaChapter(manga: null, chapter: seedChapter(id: 'c-x')),
          good2,
        ],
      ),
      listenReadHistoryUseCase: mockListenReadHistoryUseCase(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: MangaHistoryScreen(imagesCacheManager: MockImagesCacheManager()),
        ),
      ),
    );
    await pumpFrames(tester);

    expect(find.byType(ChapterTileWidget), findsNWidgets(2));
    expect(find.text('Empty Data'), findsNothing);
  });

  testWidgets('shows the empty state when histories is empty', (tester) async {
    final cubit = MangaHistoryScreenCubit(
      listenReadHistoryUseCase: mockListenReadHistoryUseCase(),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: MangaHistoryScreen(imagesCacheManager: MockImagesCacheManager()),
        ),
      ),
    );
    await pumpFrames(tester);

    expect(find.text('Empty Data'), findsOneWidget);
    expect(find.byType(ChapterTileWidget), findsNothing);
  });
}
