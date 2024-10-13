import 'package:firebase_auth/firebase_auth.dart';

import '../model/result.dart';

abstract class LoginAnonymously {
  Future<Result<User?>> loginAnonymously();
}