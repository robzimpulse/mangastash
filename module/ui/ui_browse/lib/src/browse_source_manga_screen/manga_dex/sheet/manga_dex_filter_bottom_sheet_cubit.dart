import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_dex_filter_bottom_sheet_state.dart';

class MangaDexFilterBottomSheetCubit
    extends Cubit<MangaDexFilterBottomSheetState> with AutoSubscriptionMixin {
  MangaDexFilterBottomSheetCubit({
    MangaDexFilterBottomSheetState initialState =
        const MangaDexFilterBottomSheetState(),
    required ListenListTagUseCase listenListTagUseCase,
  }) : super(
          initialState.copyWith(
            tags: listenListTagUseCase.listTagsStream.valueOrNull ?? [],
          ),
        ) {
    addSubscription(listenListTagUseCase.listTagsStream.listen(_onUpdateTags));
  }

  void _onUpdateTags(List<MangaTag> tags) {
    emit(state.copyWith(tags: tags));
  }

  Future<void> reset() async {
    emit(
      state.copyWith(
        excludedTags: state.originalExcludedTags,
        includedTags: state.originalIncludedTags,
      ),
    );
  }

  void onTapCheckbox({String? id, bool? value}) {
    if (id == null) return;

    // // set as included
    if (value == true) {
      emit(
        state.copyWith(
          includedTags: [...state.includedTags, id],
          excludedTags: [...state.excludedTags]..remove(id),
        ),
      );
    }

    // set as excluded
    if (value == false) {
      emit(
        state.copyWith(
          includedTags: [...state.includedTags]..remove(id),
          excludedTags: [...state.excludedTags, id],
        ),
      );
    }

    // set as non included and non excluded
    if (value == null) {
      emit(
        state.copyWith(
          includedTags: [...state.includedTags]..remove(id),
          excludedTags: [...state.excludedTags]..remove(id),
        ),
      );
    }
  }
}
