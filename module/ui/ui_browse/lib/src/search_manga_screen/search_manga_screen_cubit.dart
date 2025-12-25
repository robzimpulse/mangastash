import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'search_manga_screen_state.dart';

class SearchMangaScreenCubit extends Cubit<SearchMangaScreenState>
    with AutoSubscriptionMixin {
  SearchMangaScreenCubit({
    SearchMangaScreenState initialState = const SearchMangaScreenState(),
    required ListenSourcesUseCase listenSourceUseCase,
  }) : super(initialState) {
    addSubscription(
      listenSourceUseCase.sourceStateStream.distinct().listen(
        (e) => emit(state.copyWith(sources: {...e})),
      ),
    );
  }

  void set({required String keyword}) {
    emit(state.copyWith(keyword: keyword));
  }
}
