import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/subjects.dart';

import '../enum/auth_status.dart';
import '../model/auth_state.dart';
import '../service/auth_service.dart';
import '../use_case/get_auth_use_case.dart';
import '../use_case/listen_auth_use_case.dart';

class AuthManager implements ListenAuthUseCase, GetAuthUseCase {
  static final _finalizer = Finalizer<List<StreamSubscription>>(
    (events) {
      for (final event in events) {
        event.cancel();
      }
    },
  );

  final _authStateSubject = BehaviorSubject<AuthState>.seeded(
    const AuthState(status: AuthStatus.uninitialized, user: null),
  );

  AuthManager({required AuthService service}) {
    final user = service.currentUser();
    _authStateSubject.add(
      AuthState(
        status: user == null ? AuthStatus.loggedOut : AuthStatus.loggedIn,
        user: user,
      ),
    );
    _finalizer.attach(
      this,
      [service.userChanges().listen(_updateUser)],
      detach: this,
    );
  }

  @override
  ValueStream<AuthState?> get authStateStream => _authStateSubject.stream;

  @override
  AuthState? get authState => _authStateSubject.valueOrNull;

  void _updateUser(User? user) {
    _authStateSubject.add(
      AuthState(
        status: user == null ? AuthStatus.loggedOut : AuthStatus.loggedIn,
        user: user,
      ),
    );
  }
}
