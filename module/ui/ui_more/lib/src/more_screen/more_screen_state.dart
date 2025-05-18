import 'package:equatable/equatable.dart';

class MoreScreenState extends Equatable {

  final int? totalActiveDownload;

  const MoreScreenState({this.totalActiveDownload});

  @override
  List<Object?> get props => [totalActiveDownload];

  MoreScreenState copyWith({
    int? totalActiveDownload,
  }) {
    return MoreScreenState(
      totalActiveDownload: totalActiveDownload ?? this.totalActiveDownload,
    );
  }

}