import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/foundation.dart';
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

  /// Enqueues [mangas] (manga details + chapter list) for prefetching.
  /// Mangas already sitting in the job queue are skipped — re-tapping the
  /// prefetch-all button must not duplicate the workload (issue #127).
  /// The enqueued ids are emitted into state synchronously (review on
  /// #175): the mangaIdsStream hop is async, so without this a second tap
  /// before its emission reads a stale set and re-enqueues everything.
  void prefetch({required List<Manga> mangas}) {
    final queuedIds = {...state.prefetchedMangaIds};
    var didEnqueue = false;
    for (final manga in mangas) {
      final id = manga.id;
      final source = manga.source?.let(Sources.fromName);
      if (id == null || source == null) continue;
      if (queuedIds.contains(id)) continue;
      _prefetchMangaUseCase.prefetchManga(mangaId: id, source: source);
      _prefetchChapterUseCase.prefetchChapters(mangaId: id, source: source);
      queuedIds.add(id);
      didEnqueue = true;
    }
    if (didEnqueue) {
      emit(state.copyWith(prefetchedMangaIds: queuedIds));
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
  /// swallowed. A successful (or duplicate) add clears any previous error so
  /// a later equal-value failure still emits (bloc suppresses ==-equal
  /// states and Exception compares by identity).
  Future<void> add({required String url}) async {
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
      final alreadySaved = state.mangas
          .map((e) => e.id)
          .contains(result.data.id);
      if (!alreadySaved) {
        _addToLibraryUseCase.execute(manga: result.data);
      }
      _clearAddMangaError();
      return;
    }

    if (result is Error<Manga>) {
      emit(state.copyWith(addMangaError: () => result.error));
    }
  }

  /// Resets [LibraryMangaScreenState.addMangaError] when it is set — a stale
  /// error would otherwise keep the snackbar listener armed against the next
  /// identical failure.
  void _clearAddMangaError() {
    if (state.addMangaError == null) return;
    emit(state.copyWith(addMangaError: () => null));
  }

  void update({bool? isSearchActive, String? mangaTitle}) {
    // Closing search resets the title filter (issue #124): a stale title
    // would otherwise re-filter the grid invisibly the next time search is
    // opened with an empty field.
    final isClosing = isSearchActive == false;
    final ValueGetter<String?>? title;
    if (isClosing) {
      title = () => null;
    } else if (mangaTitle != null && mangaTitle.isNotEmpty) {
      title = () => mangaTitle;
    } else if (mangaTitle != null) {
      // Backspacing the field to empty fires onChanged('') — clear the
      // filter rather than storing '' (contains('') keeps titled rows but
      // hides null-titled ones; review on #159).
      title = () => null;
    } else {
      title = null;
    }
    emit(
      state.copyWith(isSearchActive: isSearchActive, mangaTitle: title),
    );
  }
}
