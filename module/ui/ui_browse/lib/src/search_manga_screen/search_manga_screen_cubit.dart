import 'package:domain_manga/domain_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'search_manga_screen_state.dart';

class SearchMangaScreenCubit extends Cubit<SearchMangaScreenState>
    with AutoSubscriptionMixin {
  SearchMangaScreenCubit({
    SearchMangaScreenState initialState = const SearchMangaScreenState(),
    required ListenSourcesUseCase listenSourceUseCase,
    required ListenSearchParameterUseCase listenSearchParameterUseCase,
  }) : super(
         initialState.copyWith(
           parameter:
               listenSearchParameterUseCase.searchParameterState.valueOrNull,
         ),
       ) {
    addSubscription(
      listenSourceUseCase.sourceStateStream.distinct().listen(
        (e) => emit(state.copyWith(sources: {...e})),
      ),
    );
  }

  void set({String? keyword, SearchMangaParameter? parameter}) {
    emit(
      state.copyWith(
        parameter: (parameter ?? state.parameter).copyWith(title: keyword),
      ),
    );
  }
}
