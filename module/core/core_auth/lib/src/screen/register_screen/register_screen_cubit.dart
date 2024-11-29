import 'package:safe_bloc/safe_bloc.dart';

import '../../../core_auth.dart';
import '../../model/result.dart';
import '../../use_case/register_use_case.dart';
import 'register_screen_state.dart';

class RegisterScreenCubit extends Cubit<RegisterScreenState>
    with AutoSubscriptionMixin {
  final RegisterUseCase _registerUseCase;

  RegisterScreenCubit({
    RegisterScreenState initialState = const RegisterScreenState(),
    required ListenAuthUseCase listenAuthUseCase,
    required RegisterUseCase registerUseCase,
  })  : _registerUseCase = registerUseCase,
        super(initialState) {
    addSubscription(
      listenAuthUseCase.authStateStream.distinct().listen(_updateAuthState),
    );
  }

  void update({String? email, String? password}) {
    emit(state.copyWith(email: email, password: password));
  }

  void _updateAuthState(AuthState? authState) {
    emit(state.copyWith(authState: authState));
  }

  void registerWithEmail() async {
    emit(state.copyWith(isLoading: true, error: () => null));

    final result = await _registerUseCase.execute(
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
