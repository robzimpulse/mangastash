import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaUpdatesScreenState extends Equatable {
  final Map<Manga, List<Chapter>> updates;

  const MangaUpdatesScreenState({this.updates = const {}});

  @override
  List<Object?> get props => [updates];

  MangaUpdatesScreenState copyWith({Map<Manga, List<Chapter>>? updates}) {
    return MangaUpdatesScreenState(
      updates: updates ?? this.updates,
    );
  }
}
