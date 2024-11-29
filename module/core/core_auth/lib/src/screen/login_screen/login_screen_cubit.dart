import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_bloc/safe_bloc.dart';

import '../../model/auth_state.dart';
import '../../model/result.dart';
import '../../use_case/listen_auth_use_case.dart';
import '../../use_case/login_anonymously_use_case.dart';
import '../../use_case/login_use_case.dart';
import 'login_screen_state.dart';

class LoginScreenCubit extends Cubit<LoginScreenState>
    with AutoSubscriptionMixin {
  final LoginAnonymouslyUseCase _loginAnonymouslyUseCase;
  final LoginUseCase _loginUseCase;

  LoginScreenCubit({
    LoginScreenState initialState = const LoginScreenState(),
    required ListenAuthUseCase listenAuthUseCase,
    required LoginUseCase loginUseCase,
    required LoginAnonymouslyUseCase loginAnonymouslyUseCase,
  })  : _loginUseCase = loginUseCase,
        _loginAnonymouslyUseCase = loginAnonymouslyUseCase,
        super(initialState) {
    addSubscription(
      listenAuthUseCase.authStateStream.distinct().listen(_updateAuthState),
    );
  }

  void update({String? email, String? password, bool? isVisible}) {
    emit(
      state.copyWith(
        email: email,
        password: password,
        isVisible: isVisible,
      ),
    );
  }

  void _updateAuthState(AuthState? authState) {
    emit(state.copyWith(authState: authState));
  }

  void login() async {
    emit(state.copyWith(isLoading: true, error: () => null));

    final result = await _loginUseCase.execute(
      email: state.email,
      password: state.password,
    );

    if (result is Success<User>) {
      emit(state.copyWith(isLoading: false, error: () => null));
    }

    if (result is Error<User>) {
      emit(state.copyWith(isLoading: false, error: () => result.error));
    }
  }

  void loginAnonymously() async {
    emit(state.copyWith(isLoading: true, error: () => null));

    final result = await _loginAnonymouslyUseCase.execute();

    if (result is Success<User>) {
      emit(state.copyWith(isLoading: false, error: () => null));
    }

    if (result is Error<User>) {
      emit(state.copyWith(isLoading: false, error: () => result.error));
    }
  }
}
