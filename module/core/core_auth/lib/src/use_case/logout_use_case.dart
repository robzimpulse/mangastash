import '../service/auth_service.dart';

class LogoutUseCase {
  final AuthService _authService;

  LogoutUseCase({
    required AuthService authService,
  }) : _authService = authService;

  Future<void> execute() => _authService.signOut();
}
