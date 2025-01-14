import 'dart:math';

import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'manga_reader_screen_state.dart';

class MangaReaderScreenCubit extends Cubit<MangaReaderScreenState>
    with AutoSubscriptionMixin {
  final GetChapterUseCase _getChapterUseCase;

  final Map<String, BehaviorSubject<double>> _pageSizeStreams = {};

  MangaReaderScreenCubit({
    required GetChapterUseCase getChapterUseCase,
    required GetMangaSourceUseCase getMangaSourceUseCase,
    required MangaReaderScreenState initialState,
  })  : _getChapterUseCase = getChapterUseCase,
        super(initialState);

  @override
  Future<void> close() async {
    await Future.wait(_pageSizeStreams.values.map((e) => e.close()));
    super.close();
  }

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    await _fetchChapter();
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _fetchChapter() async {
    final response = await _getChapterUseCase.execute(
      chapterId: state.chapterId,
      source: state.source,
      mangaId: state.mangaId,
    );

    if (response is Success<MangaChapter>) {
      final images = response.data.images ?? [];

      final List<ValueStream<double>> streams = [];
      for (final image in images) {
        final subject = _pageSizeStreams[image] ?? BehaviorSubject.seeded(0.0);
        _pageSizeStreams.putIfAbsent(image, () => subject);
        streams.add(subject.stream);
      }
      addSubscription(
        CombineLatestStream.list(streams)
            .map((event) => event.indexOf(event.reduce(max)))
            .distinct()
            .listen((event) => _onProgress(event + 1)),
      );

      emit(state.copyWith(chapter: response.data));
    }

    if (response is Error<MangaChapter>) {
      emit(state.copyWith(error: () => response.error));
    }
  }

  void onVisibility({
    required String key,
    required double visibleFraction,
  }) {
    _pageSizeStreams[key]?.add(visibleFraction);
  }

  void _onProgress(int value) {
    emit(state.copyWith(progress: value));
  }
}
