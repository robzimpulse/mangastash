import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_misc_screen_state.dart';

class MangaMiscScreenCubit extends Cubit<MangaMiscScreenState>
    with AutoSubscriptionMixin {
  MangaMiscScreenCubit({
    MangaMiscScreenState initialState = const MangaMiscScreenState(),
  }) : super(initialState);

  void update({
    ValueGetter<bool?>? downloaded,
    ValueGetter<bool?>? unread,
    ChapterDisplayEnum? display,
    ChapterSortOptionEnum? sortOption,
    ChapterSortOrderEnum? sortOrder,
  }) {
    emit(
      state.copyWith(
        config: state.config?.copyWith(
          downloaded: downloaded,
          unread: unread,
          display: display,
          sortOption: sortOption,
          sortOrder: sortOrder,
        ),
      ),
    );
  }
}
