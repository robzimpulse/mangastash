import 'package:core_auth/core_auth.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';

import 'more_screen_state.dart';

class MoreScreenCubit extends Cubit<MoreScreenState>
    with AutoSubscriptionMixin {
  final LogoutUseCase _logoutUseCase;

  MoreScreenCubit({
    MoreScreenState initialState = const MoreScreenState(),
    required ListenAuthUseCase listenAuthUseCase,
    required LogoutUseCase logoutUseCase,
    required ListenActiveDownloadUseCase listenActiveDownloadUseCase,
  })  : _logoutUseCase = logoutUseCase,
        super(initialState) {
    addSubscription(
      listenAuthUseCase.authStateStream.distinct().listen(_updateAuthState),
    );
    addSubscription(
      listenActiveDownloadUseCase.activeDownloadStream
          .distinct()
          .listen(_updateTotalActiveDownload),
    );
  }

  void _updateAuthState(AuthState? authState) {
    emit(state.copyWith(authState: authState));
  }

  void _updateTotalActiveDownload(Set<DownloadChapterKey> values) {
    emit(state.copyWith(totalActiveDownload: values.length));
  }

  Future<void> logout() => _logoutUseCase.execute();
}
