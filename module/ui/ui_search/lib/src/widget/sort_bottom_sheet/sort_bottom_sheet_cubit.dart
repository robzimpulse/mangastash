import 'package:data_manga/data_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'sort_bottom_sheet_cubit_state.dart';

class SortBottomSheetCubit extends Cubit<SortBottomSheetCubitState> {
  SortBottomSheetCubit({
    SortBottomSheetCubitState initialState = const SortBottomSheetCubitState(
      tags: [],
      original: [],
    ),
  }) : super(initialState);

  void update(Tag tag) {
    emit(
      state.copyWith(
        tags: List.from(state.tags)
          ..removeWhere((e) => e.id == tag.id)
          ..add(tag),
      ),
    );
  }

  void reset() {
    emit(state.copyWith(tags: state.original));
  }
}
