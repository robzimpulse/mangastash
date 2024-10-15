import 'package:firebase_auth/firebase_auth.dart';

import '../model/result.dart';
import '../service/auth_service.dart';

class LoginAnonymously {
  final AuthService _authService;

  LoginAnonymously({
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
