import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_reader_screen_state.dart';

class MangaReaderScreenCubit extends Cubit<MangaReaderScreenState>
    with AutoSubscriptionMixin {
  final GetChapterUseCase _getChapterUseCase;

  final CrawlUrlUseCase _crawlUrlUseCase;

  final Map<String, BehaviorSubject<double>> _pageSizeStreams = {};

  final GetMangaSourceUseCase _getMangaSourceUseCase;

  MangaReaderScreenCubit({
    required GetChapterUseCase getChapterUseCase,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    required CrawlUrlUseCase crawlUrlUseCase,
    required MangaReaderScreenState initialState,
  })  : _getChapterUseCase = getChapterUseCase,
        _getMangaSourceUseCase = getMangaSourceUseCase,
        _crawlUrlUseCase = crawlUrlUseCase,
        super(initialState);

  @override
  Future<void> close() async {
    await Future.wait(_pageSizeStreams.values.map((e) => e.close()));
    super.close();
  }

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    await Future.wait([_fetchSource(), _fetchChapter()]);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _fetchChapter() async {
    final response = await _getChapterUseCase.execute(
      chapterId: state.chapterId,
      source: state.sourceEnum,
      mangaId: state.mangaId,
    );

    if (response is Success<MangaChapter>) {
      emit(state.copyWith(chapter: response.data));
    }

    if (response is Error<MangaChapter>) {
      emit(state.copyWith(error: () => response.error));
    }
  }

  Future<void> _fetchSource() async {
    final sourceEnum = state.sourceEnum;
    if (sourceEnum == null) return;
    emit(state.copyWith(source: _getMangaSourceUseCase.get(sourceEnum)));
  }

  void recrawl() async {
    final url = state.chapter?.webUrl;
    if (url == null) return;
    await _crawlUrlUseCase.execute(url: url);
    await _fetchChapter();
  }
}
