import 'package:equatable/equatable.dart';

import '../enum/auth_status.dart';

class AuthState extends Equatable {
  final AuthStatus status;

  const AuthState(this.status);

  @override
  List<Object?> get props => [status];
}
