import 'package:data_manga/data_manga.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'advanced_search_bottom_sheet_cubit_state.dart';

class AdvancedSearchBottomSheetCubit extends Cubit<AdvancedSearchBottomSheetCubitState> {
  AdvancedSearchBottomSheetCubit({
    AdvancedSearchBottomSheetCubitState initialState = const AdvancedSearchBottomSheetCubitState(
      tags: [],
      originalTags: [],
      mode: TagsMode.and,
      originalMode: TagsMode.and
    ),
  }) : super(initialState);

  void updateTag({required int index, Tag? tag}) {
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

  void updateTagsMode(bool value) {
    emit(state.copyWith(mode: value ? TagsMode.and : TagsMode.or));
  }

  void reset() {
    emit(state.copyWith(tags: state.originalTags, mode: state.originalMode));
  }
}