import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_bloc/safe_bloc.dart';

import '../../../core_auth.dart';
import '../../enum/auth_status.dart';
import '../../model/auth_state.dart';
import '../../model/result.dart';
import '../../use_case/login_anonymously_use_case.dart';
import '../../use_case/logout_use_case.dart';
import 'login_screen_state.dart';

class LoginScreenCubit extends Cubit<LoginScreenState>
    with AutoSubscriptionMixin {
  final LoginAnonymouslyUseCase _loginAnonymously;
  final LogoutUseCase _logoutUseCase;

  LoginScreenCubit({
    LoginScreenState initialState = const LoginScreenState(),
    required ListenAuthUseCase listenAuthUseCase,
    required LoginAnonymouslyUseCase loginAnonymously,
    required LogoutUseCase logoutUseCase,
  })  : _loginAnonymously = loginAnonymously,
        _logoutUseCase = logoutUseCase,
        super(initialState) {
    addSubscription(listenAuthUseCase.authStateStream.listen(_updateAuthState));
  }

  void _updateAuthState(AuthState? authState) {
    emit(state.copyWith(authState: authState));
  }

  void loginAnonymously() async {
    emit(state.copyWith(isLoading: true, error: () => null));

    final result = await _loginAnonymously.execute();

    if (result is Success<User>) {
      emit(state.copyWith(isLoading: false, error: () => null));
    }

    if (result is Error<User>) {
      emit(state.copyWith(isLoading: false, error: () => result.error));
    }
  }

  void logout() async {
    await _logoutUseCase.execute();
  }
}
