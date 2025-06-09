import 'package:collection/collection.dart';
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
    LibraryMangaScreenState initialState = const LibraryMangaScreenState(),
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required PrefetchMangaUseCase prefetchMangaUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenPrefetchUseCase listenPrefetchMangaUseCase,
    required DownloadMangaUseCase downloadMangaUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
  })  : _prefetchMangaUseCase = prefetchMangaUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _downloadMangaUseCase = downloadMangaUseCase,
        _prefetchChapterUseCase = prefetchChapterUseCase,
        super(initialState.copyWith(sources: Source.values)) {
    addSubscription(
      listenMangaFromLibraryUseCase.libraryStateStream
          .distinct()
          .listen(_updateLibraryState),
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

  void _updatePrefetchState(Set<String> prefetchedMangaIds) {
    emit(state.copyWith(prefetchedMangaIds: prefetchedMangaIds));
  }

  void prefetch({required List<Manga> mangas}) {
    for (final manga in mangas) {
      final id = manga.id;
      final source = state.sources.firstWhereOrNull(
        (e) => e.name == manga.source?.value,
      );
      if (id == null || source == null) continue;
      _prefetchMangaUseCase.prefetchManga(
        mangaId: id,
        source: MangaSourceEnum.fromValue(source.name),
      );
      _prefetchChapterUseCase.prefetchChapters(
        mangaId: id,
        source: MangaSourceEnum.fromValue(source.name),
      );
    }
  }

  void remove({required Manga manga}) {
    _removeFromLibraryUseCase.execute(manga: manga);
  }

  void download({required Manga manga}) {
    final id = manga.id;
    final source = state.sources.firstWhereOrNull(
      (e) => e.name == manga.source?.value,
    );
    if (id == null || source == null) return;
    _downloadMangaUseCase.downloadManga(
      mangaId: id,
      source: MangaSourceEnum.fromValue(source.name),
    );
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
