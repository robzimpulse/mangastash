import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'search_manga_screen_state.dart';

class SearchMangaScreenCubit extends Cubit<SearchMangaScreenState>
    with AutoSubscriptionMixin {
  SearchMangaScreenCubit({
    SearchMangaScreenState initialState = const SearchMangaScreenState(),
    required ListenSourcesUseCase listenSourceUseCase,
  }) : super(initialState) {
    addSubscription(
      listenSourceUseCase.sourceStateStream.distinct().listen(_updateSources),
    );
  }

  void search({required String keyword}) async {
    emit(state.copyWith(keyword: keyword));
  }

  void _updateSources(List<SourceEnum> sources) {
    emit(state.copyWith(sources: sources));
    search(keyword: state.keyword);
  }
}
