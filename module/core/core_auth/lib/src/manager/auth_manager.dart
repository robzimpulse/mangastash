import 'dart:async';

import 'package:manga_service_firebase/manga_service_firebase.dart';
import 'package:rxdart/src/streams/value_stream.dart';
import 'package:rxdart/subjects.dart';

import '../enum/auth_status.dart';
import '../model/auth_state.dart';
import '../use_case/get_auth_use_case.dart';
import '../use_case/listen_auth_use_case.dart';

class AuthManager implements ListenAuthUseCase, GetAuthUseCase {
  final _authStateSubject = BehaviorSubject<AuthState>.seeded(
    const AuthState(status: AuthStatus.uninitialized, user: null),
  );

  late final StreamSubscription subscription;

  AuthManager({required AuthService service}) {
    subscription = service
        .userChanges()
        .map(
          (user) => AuthState(
            status: user == null ? AuthStatus.loggedOut : AuthStatus.loggedIn,
            user: user,
          ),
        )
        .listen(_authStateSubject.add);
  }

  Future<void> dispose() async {
    await subscription.cancel();
  }

  @override
  ValueStream<AuthState?> get authStateStream => _authStateSubject.stream;

  @override
  AuthState? get authState => _authStateSubject.valueOrNull;
}
