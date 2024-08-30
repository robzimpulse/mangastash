import 'package:rxdart/streams.dart';

import '../model/auth_state.dart';

abstract class ListenAuth {
  ValueStream<AuthState?> get authStateStream;
}
