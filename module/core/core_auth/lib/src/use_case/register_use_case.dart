import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../model/result.dart';

class RegisterUseCase {
  final AuthService _authService;

  RegisterUseCase({
    required AuthService authService,
  }) : _authService = authService;

  Future<Result<User>> execute({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authService.register(
        email: email,
        password: password,
      );
      if (result == null) throw Exception('User cannot be generated');
      return Success(result);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Error(Exception('The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        return Error(Exception('The account already exists for that email.'));
      }
      return Error(Exception(e.code));
    } catch (e) {
      return Error(e);
    }
  }
}
