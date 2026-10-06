// Widget tests for LibraryMangaScreen: a failed add-by-URL must surface a
// snackbar instead of failing silently (issue #121). Cubit-level behavior is
// covered in library_manga_screen_cubit_test.dart; this file verifies the
// screen wiring.
//
// Run with: fvm flutter test test/src/library_manga_screen/library_manga_screen_test.dart
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/sources/manga_dex_source_external.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'package:ui_browse/src/library_manga_screen/library_manga_screen.dart';
import 'package:ui_browse/src/library_manga_screen/library_manga_screen_cubit.dart';

import '../../mock/mock.dart';

class MockImagesCacheManager extends Mock implements ImagesCacheManager {}

/// Pumps [frames] of 200ms each. ScaffoldScreen contains an always-animating
/// shimmer, so pumpAndSettle never settles (see CLAUDE.md known blockers).
Future<void> pumpFrames(WidgetTester tester, [int frames = 6]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  late MockGetMangaFromUrlUseCase getMangaFromUrlUseCase;
  late LibraryMangaScreenCubit cubit;

  setUpAll(() {
    registerFallbackValue(MangaDexSourceExternal());
  });

  setUp(() {
    getMangaFromUrlUseCase = MockGetMangaFromUrlUseCase();
    cubit = LibraryMangaScreenCubit(
      getMangaFromUrlUseCase: getMangaFromUrlUseCase,
      addToLibraryUseCase: MockAddToLibraryUseCase(),
      listenMangaFromLibraryUseCase: mockListenMangaFromLibraryUseCase(),
      prefetchMangaUseCase: MockPrefetchMangaUseCase(),
      listenPrefetchMangaUseCase: mockListenPrefetchUseCase(),
      removeFromLibraryUseCase: MockRemoveFromLibraryUseCase(),
      prefetchChapterUseCase: MockPrefetchChapterUseCase(),
      listenSourcesUseCase: mockListenSourcesUseCase(),
    );
    addTearDown(cubit.close);
  });

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: LibraryMangaScreen(imagesCacheManager: _NullCacheManager()),
        ),
      ),
    );
  }

  testWidgets('shows a snackbar when the url is unsupported', (tester) async {
    await pumpScreen(tester);

    cubit.add(url: 'not a url');
    await pumpFrames(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.textContaining('Failed to add manga: Unsupported manga url'),
      findsOneWidget,
    );
  });

  testWidgets('shows a snackbar when the fetch fails', (tester) async {
    await pumpScreen(tester);
    when(
      () => getMangaFromUrlUseCase.execute(
        source: any(named: 'source'),
        url: any(named: 'url'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer((_) async => Error<Manga>(Exception('network failed')));

    cubit.add(url: 'https://asurascans.com/comics/solo-swordmaster-3ec3b16f');
    await pumpFrames(tester);

    expect(find.byType(SnackBar), findsOneWidget);
    // The "Exception: " prefix is stripped in the message.
    expect(
      find.textContaining('Failed to add manga: network failed'),
      findsOneWidget,
    );
  });

  // Issue #124: closing search only flipped isSearchActive — the field kept
  // its old text, so reopening showed an empty-looking box that still
  // filtered by the previous query.
  testWidgets('closing search clears the field for the next open', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.search));
    await pumpFrames(tester);
    await tester.enterText(find.byType(TextField), 'naruto');
    await pumpFrames(tester);

    await tester.tap(find.byIcon(Icons.close));
    await pumpFrames(tester);

    await tester.tap(find.byIcon(Icons.search));
    await pumpFrames(tester);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller?.text, '');
  });

  // Issue #131: the title filter re-ran on every keystroke. Typing now
  // debounces (300ms) through ui_common's Debounce utility.
  testWidgets('typing applies the title filter only after the debounce (#131)', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.search));
    await pumpFrames(tester);

    await tester.enterText(find.byType(TextField), 'naruto');
    // Still inside the debounce window — no filter applied yet.
    await tester.pump(const Duration(milliseconds: 150));
    expect(cubit.state.mangaTitle, isNull);

    // Past the debounce window — the filter applies with the typed value.
    await tester.pump(const Duration(milliseconds: 400));
    expect(cubit.state.mangaTitle, 'naruto');
  });

  // Submitting must apply the filter immediately (no waiting out the
  // debounce) and cancel the pending debounce so it cannot re-fire later.
  testWidgets('submitting applies the filter immediately (#131)', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.byIcon(Icons.search));
    await pumpFrames(tester);

    await tester.enterText(find.byType(TextField), 'naruto');
    await tester.pump(const Duration(milliseconds: 150));

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(cubit.state.mangaTitle, 'naruto');
  });
}

/// [ImagesCacheManager] stand-in that never touches the real cache; the grid
/// renders no items in these tests, so no member is invoked.
class _NullCacheManager extends Mock implements ImagesCacheManager {}
