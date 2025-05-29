import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'library_manga_screen_state.dart';

class LibraryMangaScreenCubit extends Cubit<LibraryMangaScreenState>
    with AutoSubscriptionMixin {
  final PrefetchMangaUseCase _prefetchMangaUseCase;
  final RemoveFromLibraryUseCase _removeFromLibraryUseCase;

  LibraryMangaScreenCubit({
    required LibraryMangaScreenState initialState,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required ListenMangaSourceUseCase listenMangaSourceUseCase,
    required PrefetchMangaUseCase prefetchMangaUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenPrefetchUseCase listenPrefetchMangaUseCase,
  })  : _prefetchMangaUseCase = prefetchMangaUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
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
      listenPrefetchMangaUseCase.prefetchedStream
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

  void _updatePrefetchState(Map<String, Set<String>> prefetchedMangaIds) {
    emit(state.copyWith(prefetchedMangaIds: [...prefetchedMangaIds.keys]));
  }

  void prefetch({required List<Manga> mangas}) {
    for (final manga in mangas) {
      final id = manga.id;
      final source = manga.source;
      if (id == null || source == null) continue;
      _prefetchMangaUseCase.prefetchManga(mangaId: id, source: source);
    }
  }

  void remove({required Manga manga}) {
    _removeFromLibraryUseCase.execute(manga: manga);
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
