import 'package:core_auth/core_auth.dart';
import 'package:core_network/core_network.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'library_manga_state.dart';

class LibraryMangaCubit extends Cubit<LibraryMangaState> with AutoSubscriptionMixin{
  final GetMangaFromLibraryUseCase _getMangaFromLibraryUseCase;

  LibraryMangaCubit({
    required LibraryMangaState initialState,
    required GetMangaFromLibraryUseCase getMangaFromLibraryUseCase,
    required ListenAuthUseCase listenAuthUseCase,
  })  : _getMangaFromLibraryUseCase = getMangaFromLibraryUseCase,
        super(initialState) {
    addSubscription(listenAuthUseCase.authStateStream.listen(_updateAuthState));
  }

  void _updateAuthState(AuthState? authState) {
    emit(state.copyWith(authState: authState));
    init();
  }

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    final userId = state.authState?.user?.uid;

    if (userId == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    final result = await _getMangaFromLibraryUseCase.execute(userId: userId);

    if (result is Success<List<Manga>>) {
      emit(state.copyWith(mangas: result.data));
    }

    emit(state.copyWith(isLoading: false));
  }
}
