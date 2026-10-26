// Tests for MangaMiscScreen's Display tab: the chapter display radios must
// reflect the cubit's config and write the tapped value back through
// MangaMiscScreenCubit.update. Selection is asserted via semantics so the
// test holds whether the group value sits on each RadioListTile (pre-3.32
// API) or on a RadioGroup ancestor (Flutter 3.47 migration).
//
// Run with: fvm flutter test test/src/manga_misc_screen/manga_misc_screen_test.dart
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'package:ui_browse/src/manga_misc_screen/manga_misc_screen.dart';
import 'package:ui_browse/src/manga_misc_screen/manga_misc_screen_cubit.dart';
import 'package:ui_browse/src/manga_misc_screen/manga_misc_screen_state.dart';

void main() {
  Future<MangaMiscScreenCubit> pumpDisplayTab(WidgetTester tester) async {
    final cubit = MangaMiscScreenCubit(
      initialState: const MangaMiscScreenState(config: ChapterConfig()),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const MangaMiscScreen(),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Display'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    return cubit;
  }

  Finder tile(ChapterDisplayEnum display) {
    return find.widgetWithText(
      RadioListTile<ChapterDisplayEnum>,
      display.value,
    );
  }

  testWidgets('shows the configured display as selected', (tester) async {
    await pumpDisplayTab(tester);

    expect(
      tester.getSemantics(tile(ChapterDisplayEnum.title)),
      isSemantics(isChecked: true),
    );
    expect(
      tester.getSemantics(tile(ChapterDisplayEnum.chapter)),
      isSemantics(isChecked: false),
    );
  });

  testWidgets('tapping a display updates the cubit and the selection', (
    tester,
  ) async {
    final cubit = await pumpDisplayTab(tester);

    await tester.tap(tile(ChapterDisplayEnum.chapter));
    await tester.pump();

    expect(cubit.state.config?.display, ChapterDisplayEnum.chapter);
    expect(
      tester.getSemantics(tile(ChapterDisplayEnum.chapter)),
      isSemantics(isChecked: true),
    );
    expect(
      tester.getSemantics(tile(ChapterDisplayEnum.title)),
      isSemantics(isChecked: false),
    );
  });
}
