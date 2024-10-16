import '../model/auth_state.dart';

abstract class GetAuthUseCase {
  AuthState? get authState;
}
