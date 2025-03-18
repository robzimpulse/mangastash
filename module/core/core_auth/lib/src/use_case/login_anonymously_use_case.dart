import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../model/result.dart';

class LoginAnonymouslyUseCase {
  final AuthService _authService;

  LoginAnonymouslyUseCase({
    required AuthService authService,
  }) : _authService = authService;

  Future<Result<User>> execute() async {
    try {
      final result = await _authService.signInAnonymously();
      if (result == null) throw Exception('User cannot be generated');
      return Success(result);
    } catch (e) {
      return Error(e);
    }
  }
}
