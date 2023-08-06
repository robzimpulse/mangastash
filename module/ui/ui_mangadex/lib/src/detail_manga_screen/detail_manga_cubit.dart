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
  }) : super(
          initialState.copyWith(
            manga: manga,
            parameter: SearchChapterParameter(
              mangaId: manga.id,
              translatedLanguage: const [LanguageCodes.english],
              orders: const {ChapterOrders.chapter: OrderDirections.descending},
            ),
          ),
        );

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    await _fetchAllChapter();
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _fetchAllChapter() async {
    var param = state.parameter.copyWith(limit: 100);
    List<MangaChapter> chapters = [];
    var total = 0;

    do {
      final response = await searchChapterUseCase.execute(parameter: param);
      if (response is Error<SearchChapterResponse>) {
        emit(state.copyWith(errorMessage: () => response.error.toString()));
        break;
      }
      if (response is Success<SearchChapterResponse>) {
        final data = response.data.data ?? [];
        final offset = response.data.offset ?? 0;
        final limit = response.data.limit ?? 0;
        total = response.data.total ?? 0;
        chapters.addAll(
          data.map(
            (e) => MangaChapter(
              id: e.id,
              chapter: e.attributes?.chapter,
              title: e.attributes?.title,
            ),
          ),
        );
        param = param.copyWith(offset: offset + limit);
      }
    } while (chapters.length < total);

    emit(state.copyWith(manga: state.manga?.copyWith(chapters: chapters)));
  }
}
