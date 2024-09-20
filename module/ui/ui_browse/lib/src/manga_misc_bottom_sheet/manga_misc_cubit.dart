import 'package:flutter/foundation.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_misc_state.dart';

class MangaMiscCubit extends Cubit<MangaMiscState> with AutoSubscriptionMixin {
  MangaMiscCubit({
    MangaMiscState initialState = const MangaMiscState(),
  }) : super(initialState);

  void update({
    ValueGetter<bool?>? downloaded,
    ValueGetter<bool?>? unread,
    ValueGetter<bool?>? bookmarked,
    MangaMiscDisplayEnum? display,
    MangaMiscSortOptionEnum? sortOption,
    MangaMiscSortOrderEnum? sortOrder,
  }) {
    emit(
      state.copyWith(
        downloaded: downloaded,
        unread: unread,
        bookmarked: bookmarked,
        display: display,
        sortOption: sortOption,
        sortOrder: sortOrder,
      ),
    );
  }
}
