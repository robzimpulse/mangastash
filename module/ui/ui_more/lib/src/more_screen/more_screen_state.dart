import 'package:core_auth/core_auth.dart';
import 'package:equatable/equatable.dart';

class MoreScreenState extends Equatable {

  final AuthState? authState;

  const MoreScreenState({this.authState});

  @override
  List<Object?> get props => [authState];

  MoreScreenState copyWith({
    AuthState? authState,
  }) {
    return MoreScreenState(
      authState: authState ?? this.authState,
    );
  }

}