import 'package:equatable/equatable.dart';

class MoreScreenState extends Equatable {
  final int jobCount;

  const MoreScreenState({this.jobCount = 0});

  @override
  List<Object?> get props => [jobCount];

  MoreScreenState copyWith({
    int? jobCount,
  }) {
    return MoreScreenState(
      jobCount: jobCount ?? this.jobCount,
    );
  }
}
