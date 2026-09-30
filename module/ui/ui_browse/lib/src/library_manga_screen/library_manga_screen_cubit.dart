import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'library_manga_screen_state.dart';

class LibraryMangaScreenCubit extends Cubit<LibraryMangaScreenState>
    with AutoSubscriptionMixin {
  final PrefetchMangaUseCase _prefetchMangaUseCase;
  final PrefetchChapterUseCase _prefetchChapterUseCase;
  final RemoveFromLibraryUseCase _removeFromLibraryUseCase;
  final GetMangaFromUrlUseCase _getMangaFromUrlUseCase;
  final AddToLibraryUseCase _addToLibraryUseCase;

  LibraryMangaScreenCubit({
    LibraryMangaScreenState initialState = const LibraryMangaScreenState(),
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required PrefetchMangaUseCase prefetchMangaUseCase,
    required RemoveFromLibraryUseCase removeFromLibraryUseCase,
    required ListenPrefetchUseCase listenPrefetchMangaUseCase,
    required PrefetchChapterUseCase prefetchChapterUseCase,
    required GetMangaFromUrlUseCase getMangaFromUrlUseCase,
    required AddToLibraryUseCase addToLibraryUseCase,
    required ListenSourcesUseCase listenSourcesUseCase,
  })  : _prefetchMangaUseCase = prefetchMangaUseCase,
        _addToLibraryUseCase = addToLibraryUseCase,
        _removeFromLibraryUseCase = removeFromLibraryUseCase,
        _prefetchChapterUseCase = prefetchChapterUseCase,
        _getMangaFromUrlUseCase = getMangaFromUrlUseCase,
        super(
          initialState.copyWith(
            sources: listenSourcesUseCase.sourceStateStream.valueOrNull ?? const [],
          ),
        ) {
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
    addSubscription(
      listenSourcesUseCase.sourceStateStream.distinct().listen(
        (sources) => emit(state.copyWith(sources: sources)),
      ),
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
      final source = manga.source?.let(Sources.fromName);
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
    // TODO: add download manga
  }

  /// Adds a manga from a pasted [url]. Failures (unparseable URL, unknown
  /// source host, or a failed fetch) emit [LibraryMangaScreenState.addMangaError]
  /// — surfaced as a snackbar by the screen — instead of being silently
  /// swallowed.
  void add({required String url}) async {
    final uri = Uri.tryParse(url);
    final source = uri?.source;
    if (uri == null || source == null) {
      emit(
        state.copyWith(
          addMangaError: () => Exception('Unsupported manga url: $url'),
        ),
      );
      return;
    }

    final result = await _getMangaFromUrlUseCase.execute(
      source: source,
      url: url,
    );

    if (result is Success<Manga>) {
      if (state.mangas.map((e) => e.id).contains(result.data.id)) return;
      _addToLibraryUseCase.execute(manga: result.data);
      return;
    }

    if (result is Error<Manga>) {
      emit(state.copyWith(addMangaError: () => result.error));
    }
  }

  void update({bool? isSearchActive, String? mangaTitle}) {
    emit(
      state.copyWith(isSearchActive: isSearchActive, mangaTitle: mangaTitle),
    );
  }
}
