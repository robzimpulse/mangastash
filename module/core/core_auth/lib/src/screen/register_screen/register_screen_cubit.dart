import 'package:safe_bloc/safe_bloc.dart';

import 'register_screen_state.dart';

class RegisterScreenCubit extends Cubit<RegisterScreenState> {
  RegisterScreenCubit({
    RegisterScreenState initialState = const RegisterScreenState(),
  }) : super(initialState);
}
