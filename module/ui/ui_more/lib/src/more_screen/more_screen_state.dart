import 'package:equatable/equatable.dart';

class MoreScreenState extends Equatable {
  final int jobCount;
  final bool isDownloadedOnly;
  final bool isIncognito;

  const MoreScreenState({
    this.jobCount = 0,
    this.isDownloadedOnly = false,
    this.isIncognito = false,
  });

  @override
  List<Object?> get props => [jobCount, isDownloadedOnly, isIncognito];

  MoreScreenState copyWith({
    int? jobCount,
    bool? isDownloadedOnly,
    bool? isIncognito,
  }) {
    return MoreScreenState(
      jobCount: jobCount ?? this.jobCount,
      isDownloadedOnly: isDownloadedOnly ?? this.isDownloadedOnly,
      isIncognito: isIncognito ?? this.isIncognito,
    );
  }
}
