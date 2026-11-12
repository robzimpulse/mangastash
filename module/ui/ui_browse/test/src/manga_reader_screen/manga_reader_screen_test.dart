// Widget tests for MangaReaderScreen's error actions.
//
// Issue #206: a chapter whose source moved away from its stored host fails
// with SourceMovedException. Nothing can be recovered from the dead host, so
// the reader must offer no "Open Debug Browser" (nor Retry / Fix source) for
// it, while any other load error keeps the debug-browser action.
//
// The cubit is a mocktail double whose `state` is fixed, so the screen is
// rendered in its error state without the real use cases. ScaffoldScreen
// animates forever (shimmer, indeterminate progress), so frames are pumped
// explicitly instead of `pumpAndSettle` (CLAUDE.md §6).
import 'package:core_analytics/core_analytics.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_browse/src/manga_reader_screen/manga_reader_screen.dart';
import 'package:ui_browse/src/manga_reader_screen/manga_reader_screen_cubit.dart';
import 'package:ui_browse/src/manga_reader_screen/manga_reader_screen_state.dart';

class _MockCubit extends Mock implements MangaReaderScreenCubit {}

class _MockImagesCacheManager extends Mock implements ImagesCacheManager {}

class _MockLogBox extends Mock implements LogBox {}

void main() {
  late _MockCubit cubit;

  setUp(() {
    cubit = _MockCubit();
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.close()).thenAnswer((_) async {});
  });

  /// Renders the reader with [cubit] fixed in an error state for [error].
  Future<void> pumpReader(WidgetTester tester, Exception error) async {
    when(() => cubit.state).thenReturn(
      MangaReaderScreenState(isLoading: false, error: error),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<MangaReaderScreenCubit>.value(
          value: cubit,
          child: MangaReaderScreen(
            imagesCacheManager: _MockImagesCacheManager(),
            logBox: _MockLogBox(),
            onTapFixSource: (_) {},
          ),
        ),
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('a moved-source error offers no debug browser (#206)', (
    tester,
  ) async {
    const error = SourceMovedException(
      sourceName: 'Weeb Central',
      host: 'weebcentral.com',
    );

    await pumpReader(tester, error);

    expect(find.text(error.toString()), findsOneWidget);
    expect(find.text('Open Debug Browser'), findsNothing);
    expect(find.text('Retry'), findsNothing);
    expect(find.text('Fix source'), findsNothing);
  });

  testWidgets('any other load error still offers the debug browser', (
    tester,
  ) async {
    await pumpReader(tester, Exception('boom'));

    expect(find.text('Open Debug Browser'), findsOneWidget);
  });
}
