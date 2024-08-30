import 'package:safe_bloc/safe_bloc.dart';

import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({
    RegisterState initialState = const RegisterState(),
  }) : super(initialState);
}
