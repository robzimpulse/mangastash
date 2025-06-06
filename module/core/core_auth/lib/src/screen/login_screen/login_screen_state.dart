import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../core_auth.dart';

class LoginScreenState extends Equatable {
  const LoginScreenState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.isVisible = true,
    this.authState,
    this.error,
  });

  final bool isVisible;

  final bool isLoading;

  final String email;

  final String password;

  final AuthState? authState;

  final Exception? error;

  @override
  List<Object?> get props => [
        isLoading,
        authState,
        error,
        email,
        password,
        isVisible,
      ];

  LoginScreenState copyWith({
    bool? isLoading,
    bool? isVisible,
    String? email,
    String? password,
    AuthState? authState,
    ValueGetter<Exception?>? error,
  }) {
    return LoginScreenState(
      isVisible: isVisible ?? this.isVisible,
      isLoading: isLoading ?? this.isLoading,
      authState: authState ?? this.authState,
      error: error != null ? error() : this.error,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
