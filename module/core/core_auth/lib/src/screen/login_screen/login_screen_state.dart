import 'package:equatable/equatable.dart';

class LoginScreenState extends Equatable {
  const LoginScreenState({this.isLoading = false});

  final bool isLoading;

  @override
  List<Object?> get props => [isLoading];

  LoginScreenState copyWith({bool? isLoading}) {
    return LoginScreenState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
