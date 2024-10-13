import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../enum/auth_status.dart';

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;

  const AuthState({required this.status, this.user});

  @override
  List<Object?> get props => [status, user];
}
