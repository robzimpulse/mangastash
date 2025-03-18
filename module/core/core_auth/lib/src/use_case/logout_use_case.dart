import 'package:manga_service_firebase/manga_service_firebase.dart';

class LogoutUseCase {
  final AuthService _authService;

  LogoutUseCase({
    required AuthService authService,
  }) : _authService = authService;

  Future<void> execute() => _authService.signOut();
}
