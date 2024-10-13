import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_bloc/safe_bloc.dart';

import '../../../core_auth.dart';
import '../../model/result.dart';
import '../../use_case/login_anonymously.dart';
import 'login_screen_state.dart';

class LoginScreenCubit extends Cubit<LoginScreenState>
    with AutoSubscriptionMixin {
  final LoginAnonymously _loginAnonymously;

  LoginScreenCubit({
    LoginScreenState initialState = const LoginScreenState(),
    required LoginAnonymously loginAnonymously,
  })  : _loginAnonymously = loginAnonymously,
        super(initialState);

  void loginAnonymously() async {
    emit(state.copyWith(isLoading: true, error: () => null));
    final result = await _loginAnonymously.loginAnonymously();

    if (result is Success<UserCredential>) {
      emit(
        state.copyWith(
          isLoading: false,
          authState: AuthState(
            status: AuthStatus.loggedIn,
            user: result.data.user,
          ),
        ),
      );
    }

    if (result is Error<UserCredential>) {
      emit(state.copyWith(isLoading: false, error: () => result.error));
    }
  }
}
