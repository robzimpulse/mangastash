import 'package:rxdart/streams.dart';

import '../model/auth_state.dart';

abstract class ListenAuthUseCase {
  ValueStream<AuthState?> get authStateStream;
}
