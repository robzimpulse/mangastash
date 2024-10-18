import 'package:core_auth/core_auth.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'library_manga_screen_state.dart';

class LibraryMangaScreenCubit extends Cubit<LibraryMangaScreenState>
    with AutoSubscriptionMixin {
  LibraryMangaScreenCubit({
    required LibraryMangaScreenState initialState,
    required ListenMangaFromLibraryUseCase listenMangaFromLibraryUseCase,
    required ListenAuthUseCase listenAuthUseCase,
  }) : super(initialState) {
    addSubscription(
      listenAuthUseCase.authStateStream.listen(_updateAuthState),
    );
    addSubscription(
      listenMangaFromLibraryUseCase.libraryStateStream
          .listen(_updateLibraryState),
    );
  }

  void _updateAuthState(AuthState? authState) {
    emit(state.copyWith(authState: authState));
  }

  void _updateLibraryState(List<Manga> libraryState) {
    emit(state.copyWith(mangas: libraryState));
  }
}
