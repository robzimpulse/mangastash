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

  void update({required int index, Tag? tag}) {
    var updated = tag;
    if (updated == null) return;

    if (index == 0) {
      updated = updated.copyWith(
        isExcluded: !updated.isExcluded,
        isIncluded: !updated.isExcluded == true ? false : null,
      );
    }

    if (index == 1) {
      updated = updated.copyWith(
        isIncluded: !updated.isIncluded,
        isExcluded: !updated.isIncluded == true ? false : null,
      );
    }

    emit(
      state.copyWith(
        tags: List.from(state.tags)
          ..removeWhere((e) => e.id == updated?.id)
          ..add(updated),
      ),
    );
  }

  void reset() {
    emit(state.copyWith(tags: state.original));
  }
}
