import 'package:core_auth/core_auth.dart';
import 'package:equatable/equatable.dart';

class MoreScreenState extends Equatable {

  final AuthState? authState;

  final int? totalActiveDownload;

  const MoreScreenState({this.authState, this.totalActiveDownload});

  @override
  List<Object?> get props => [authState, totalActiveDownload];

  MoreScreenState copyWith({
    AuthState? authState,
    int? totalActiveDownload,
  }) {
    return MoreScreenState(
      authState: authState ?? this.authState,
      totalActiveDownload: totalActiveDownload ?? this.totalActiveDownload,
    );
  }

}