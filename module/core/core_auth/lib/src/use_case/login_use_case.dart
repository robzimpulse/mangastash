import 'package:firebase_auth/firebase_auth.dart';

import '../model/result.dart';
import '../service/auth_service.dart';

class LoginUseCase {
  final AuthService _authService;

  LoginUseCase({
    required AuthService authService,
  }) : _authService = authService;

  Future<Result<User>> execute({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authService.login(email: email, password: password);
      if (result == null) return Error(Exception('User cannot be generated'));
      return Success(result);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return Error(Exception('No user found for that email.'));
      } else if (e.code == 'wrong-password') {
        return Error(Exception('Wrong password provided for that user.'));
      }
      return Error(Exception(e.code));
    } catch (e) {
      return Error(e);
    }
  }
}
