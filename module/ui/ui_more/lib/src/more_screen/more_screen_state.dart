import 'package:equatable/equatable.dart';

class MoreScreenState extends Equatable {
  final int jobCount;
  final bool isDownloadedOnly;

  const MoreScreenState({this.jobCount = 0, this.isDownloadedOnly = false});

  @override
  List<Object?> get props => [jobCount, isDownloadedOnly];

  MoreScreenState copyWith({
    int? jobCount,
    bool? isDownloadedOnly
  }) {
    return MoreScreenState(
      jobCount: jobCount ?? this.jobCount,
      isDownloadedOnly: isDownloadedOnly ?? this.isDownloadedOnly,
    );
  }
}
