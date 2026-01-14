import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaHistoryScreenState extends Equatable {
  final List<History> histories;

  const MangaHistoryScreenState({this.histories = const []});

  @override
  List<Object?> get props => [histories];

  MangaHistoryScreenState copyWith({List<History>? histories}) {
    return MangaHistoryScreenState(
      histories: histories ?? this.histories,
    );
  }
}
