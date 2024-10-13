import 'package:safe_bloc/safe_bloc.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    LoginState initialState = const LoginState(),
  }) : super(initialState);
}
