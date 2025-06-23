import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaUpdatesScreenState extends Equatable {
  final Map<Manga, List<Chapter>> updates;
  final List<Manga> libraries;

  const MangaUpdatesScreenState({
    this.updates = const {},
    this.libraries = const [],
  });

  @override
  List<Object?> get props => [updates, libraries];

  MangaUpdatesScreenState copyWith({
    Map<Manga, List<Chapter>>? updates,
    List<Manga>? libraries,
  }) {
    return MangaUpdatesScreenState(
      updates: updates ?? this.updates,
      libraries: libraries ?? this.libraries,
    );
  }
}
