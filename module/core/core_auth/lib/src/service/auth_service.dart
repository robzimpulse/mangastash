import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseApp _app;

  late final _firebaseAuth = FirebaseAuth.instanceFor(app: _app);

  AuthService({required FirebaseApp app}) : _app = app;

  User? currentUser() => _firebaseAuth.currentUser;

  Future<User?> signInAnonymously() {
    return _firebaseAuth.signInAnonymously().then((value) => value.user);
  }

  Stream<User?> userChanges() => _firebaseAuth.userChanges();
}