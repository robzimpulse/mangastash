import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../core_auth.dart';

class LoginScreenState extends Equatable {
  const LoginScreenState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.authState,
    this.error,
  });

  final bool isLoading;

  final String email;

  final String password;

  final AuthState? authState;

  final Exception? error;

  @override
  List<Object?> get props => [isLoading, authState, error];

  LoginScreenState copyWith({
    bool? isLoading,
    String? email,
    String? password,
    AuthState? authState,
    ValueGetter<Exception?>? error,
  }) {
    return LoginScreenState(
      isLoading: isLoading ?? this.isLoading,
      authState: authState ?? this.authState,
      error: error != null ? error() : this.error,
    );
  }
}
