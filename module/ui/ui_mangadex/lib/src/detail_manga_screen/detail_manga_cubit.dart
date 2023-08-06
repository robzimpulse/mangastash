import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'detail_manga_state.dart';

class DetailMangaCubit extends Cubit<DetailMangaState> {
  final SearchChapterUseCase searchChapterUseCase;

  DetailMangaCubit({
    required Manga manga,
    required this.searchChapterUseCase,
    DetailMangaState initialState = const DetailMangaState(),
  }) : super(initialState.copyWith(manga: manga));

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    final id = state.manga?.id;

    if (id == null) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: () => 'Manga id Empty',
        ),
      );
      return;
    }

    final response = await searchChapterUseCase.execute(
      parameter: SearchChapterParameter(
        mangaId: id,
        limit: 100,
        orders: const {
          ChapterOrders.chapter: OrderDirections.descending,
        },
      ),
    );

    if (response is Success<SearchChapterResponse>) {
      emit(
        state.copyWith(
          manga: state.manga?.copyWith(
            chapters: response.data.data
                ?.map(
                  (e) => MangaChapter(
                    id: e.id,
                    chapter: e.attributes?.chapter,
                    title: e.attributes?.title,
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    if (response is Error<SearchChapterResponse>) {
      emit(state.copyWith(errorMessage: () => response.error.toString()));
    }

    emit(state.copyWith(isLoading: false));
  }
}
