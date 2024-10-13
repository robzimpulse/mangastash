import 'package:safe_bloc/safe_bloc.dart';

import '../../use_case/login_anonymously.dart';
import 'login_screen_state.dart';

class LoginScreenCubit extends Cubit<LoginScreenState> {
  final LoginAnonymously _loginAnonymously;

  LoginScreenCubit({
    LoginScreenState initialState = const LoginScreenState(),
    required LoginAnonymously loginAnonymously,
  })  : _loginAnonymously = loginAnonymously,
        super(initialState);

  void loginAnonymously() async {
    emit(state.copyWith(isLoading: true));

    await _loginAnonymously.loginAnonymously();

    emit(state.copyWith(isLoading: false));
  }
}
