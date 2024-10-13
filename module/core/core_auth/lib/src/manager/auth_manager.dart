import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/subjects.dart';

import '../enum/auth_status.dart';
import '../model/auth_state.dart';
import '../use_case/get_auth.dart';
import '../use_case/listen_auth.dart';
import '../use_case/login_anonymously.dart';
import '../use_case/update_auth.dart';

class AuthManager implements ListenAuth, UpdateAuth, GetAuth, LoginAnonymously {

  final FirebaseApp _app;

  final _authStateSubject = BehaviorSubject<AuthState>.seeded(
    const AuthState(status: AuthStatus.uninitialized, user: null),
  );

  late final _firebaseAuth = FirebaseAuth.instanceFor(app: _app);

  AuthManager({required FirebaseApp app}): _app = app {
    _firebaseAuth.authStateChanges().listen(_updateUser);
  }

  @override
  ValueStream<AuthState?> get authStateStream => _authStateSubject.stream;

  @override
  AuthState? get authState => _authStateSubject.valueOrNull;

  @override
  void updateAuth(AuthState state) => _authStateSubject.add(state);

  @override
  Future<bool> loginAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _updateUser(User? user) {
    if (user == null) {
      updateAuth(const AuthState(status: AuthStatus.loggedOut, user: null));
    } else {
      updateAuth(AuthState(status: AuthStatus.loggedIn, user: user));
    }
  }
}
