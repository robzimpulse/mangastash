import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'library_manga_screen_state.dart';

class LibraryMangaScreenCubit extends Cubit<LibraryMangaScreenState>
    with AutoSubscriptionMixin {
  final GetMangaFromLibraryUseCase _getMangaFromLibraryUseCase;

  LibraryMangaScreenCubit({
    required LibraryMangaScreenState initialState,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required ListenMangaSourceUseCase listenMangaSourceUseCase,
    required GetMangaFromLibraryUseCase getMangaFromLibraryUseCase,
  })  : _getMangaFromLibraryUseCase = getMangaFromLibraryUseCase,
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
  }

  void _updateLibraryState(List<String> libraryState) async {
    emit(
      state.copyWith(
        mangas: await _getMangaFromLibraryUseCase.libraryState,
      ),
    );
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
