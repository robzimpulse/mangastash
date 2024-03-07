import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/subjects.dart';

import '../enum/auth_status.dart';
import '../model/auth_state.dart';
import '../use_case/get_auth.dart';
import '../use_case/listen_auth.dart';
import '../use_case/update_auth.dart';

class AuthManager implements ListenAuth, UpdateAuth, GetAuth {
  final _authStateSubject = BehaviorSubject<AuthState>.seeded(
    const AuthState(AuthStatus.uninitialized),
  );

  @override
  ValueStream<AuthState?> get authStateStream => _authStateSubject.stream;

  @override
  AuthState? get authState => _authStateSubject.valueOrNull;

  @override
  void updateAuth(AuthState state) {
    _authStateSubject.add(state);
  }
}
