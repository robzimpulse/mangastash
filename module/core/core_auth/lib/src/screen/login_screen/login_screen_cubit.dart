import 'package:safe_bloc/safe_bloc.dart';

import '../../../core_auth.dart';
import '../../model/result.dart';
import '../../use_case/login_use_case.dart';
import 'login_screen_state.dart';

class LoginScreenCubit extends Cubit<LoginScreenState>
    with AutoSubscriptionMixin {
  final LoginUseCase _loginUseCase;

  LoginScreenCubit({
    LoginScreenState initialState = const LoginScreenState(),
    required ListenAuthUseCase listenAuthUseCase,
    required LoginUseCase loginUseCase,
  })  : _loginUseCase = loginUseCase,
        super(initialState) {
    addSubscription(listenAuthUseCase.authStateStream.listen(_updateAuthState));
  }

  void update({String? email, String? password}) {
    emit(state.copyWith(email: email, password: password));
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
}
