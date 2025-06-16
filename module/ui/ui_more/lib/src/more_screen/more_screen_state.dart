import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

class MoreScreenState extends Equatable {

  final int? totalActiveDownload;

  final int? totalActiveJob;

  int get totalActiveQueue {
    return [totalActiveJob, totalActiveDownload].nonNulls.sum;
  }

  const MoreScreenState({this.totalActiveDownload, this.totalActiveJob});

  @override
  List<Object?> get props => [totalActiveDownload, totalActiveJob];

  MoreScreenState copyWith({
    int? totalActiveDownload,
    int? totalActiveJob,
  }) {
    return MoreScreenState(
      totalActiveDownload: totalActiveDownload ?? this.totalActiveDownload,
      totalActiveJob: totalActiveJob ?? this.totalActiveJob,
    );
  }

}