import 'package:data_manga/data_manga.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'advanced_search_bottom_sheet_cubit_state.dart';

class AdvancedSearchBottomSheetCubit extends Cubit<AdvancedSearchBottomSheetCubitState> {
  AdvancedSearchBottomSheetCubit({
    AdvancedSearchBottomSheetCubitState initialState = const AdvancedSearchBottomSheetCubitState(
      tags: [],
      original: SearchMangaParameter(),
      parameter: SearchMangaParameter(),
    ),
  }) : super(initialState);

  void updateTag({required int index, Tag? tag}) {
    final id = tag?.id;

    if (id == null) return;

    var parameter = state.parameter;

    if (index == 0) {
      parameter = parameter.copyWith(
        includedTags: List.of(parameter.includedTags)..remove(id),
        excludedTags: List.of(parameter.excludedTags)..add(id),
      );
    }

    if (index == 1) {
      parameter = parameter.copyWith(
        includedTags: List.of(parameter.includedTags)..add(id),
        excludedTags: List.of(parameter.excludedTags)..remove(id),
      );
    }

    emit(state.copyWith(parameter: parameter));
  }

  void updateTagsMode({required bool isIncludedTag, required bool value}) {
    var parameter = state.parameter;

    final mode = value ? TagsMode.and : TagsMode.or;

    parameter = parameter.copyWith(
      includedTagsMode: isIncludedTag ? mode : null,
      excludedTagsMode: isIncludedTag ? null : mode,
    );

    emit(state.copyWith(parameter: parameter));
  }

  void reset() {
    emit(state.copyWith(parameter: state.original));
  }
}