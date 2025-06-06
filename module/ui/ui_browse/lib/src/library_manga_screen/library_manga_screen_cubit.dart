import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'library_manga_screen_state.dart';

class LibraryMangaScreenCubit extends Cubit<LibraryMangaScreenState>
    with AutoSubscriptionMixin {
  final PrefetchMangaUseCase _prefetchMangaUseCase;
  final PrefetchChapterUseCase _prefetchChapterUseCase;
  final RemoveFromLibraryUseCase _removeFromLibraryUseCase;
  final DownloadMangaUseCase _downloadMangaUseCase;

  LibraryMangaScreenCubit({
    required LibraryMangaScreenState initialState,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required ListenMangaSourceUseCase listenMangaSourceUseCase,
    required PrefetchMangaUseCase prefetchMangaUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenPrefetchUseCase listenPrefetchMangaUseCase,
    required DownloadMangaUseCase downloadMangaUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
  })  : _prefetchMangaUseCase = prefetchMangaUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _downloadMangaUseCase = downloadMangaUseCase,
        _prefetchChapterUseCase = prefetchChapterUseCase,
        super(initialState) {
    addSubscription(
      listenMangaFromLibraryUseCase.libraryStateStream
          .distinct()
          .listen(_updateLibraryState),
    );
    addSubscription(
      listenMangaSourceUseCase.mangaSourceStateStream
          .distinct()
          .listen(_updateSourceState),
    );

    addSubscription(
      listenPrefetchMangaUseCase.mangaIdsStream
          .distinct()
          .listen(_updatePrefetchState),
    );
  }

  void _updateLibraryState(List<Manga> libraryState) async {
    emit(state.copyWith(mangas: libraryState));
  }

  void _updateSourceState(Map<String, MangaSource> sources) {
    emit(
      state.copyWith(
        sources: {
          for (final source in sources.values) source.name: source,
        },
      ),
    );
  }

  void _updatePrefetchState(Set<String> prefetchedMangaIds) {
    emit(state.copyWith(prefetchedMangaIds: prefetchedMangaIds));
  }

  void prefetch({required List<Manga> mangas}) {
    for (final manga in mangas) {
      final id = manga.id;
      final source = manga.source;
      if (id == null || source == null) continue;
      _prefetchMangaUseCase.prefetchManga(mangaId: id, source: source);
      _prefetchChapterUseCase.prefetchChapters(mangaId: id, source: source);
    }
  }

  void remove({required Manga manga}) {
    _removeFromLibraryUseCase.execute(manga: manga);
  }

  void download({required Manga manga}) {
    final id = manga.id;
    final source = manga.source;
    if (id == null || source == null) return;
    _downloadMangaUseCase.downloadManga(mangaId: id, source: source);
  }

  void update({
    MangaShelfItemLayout? layout,
    bool? isSearchActive,
    String? mangaTitle,
  }) {
    emit(
      state.copyWith(
        layout: layout,
        isSearchActive: isSearchActive,
        mangaTitle: mangaTitle,
      ),
    );
  }
}
