import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaMiscScreenState extends Equatable {

  final MangaChapterConfig? config;

  const MangaMiscScreenState({
    this.config,
  });

  MangaMiscScreenState copyWith({
    MangaChapterConfig? config,
  }) {
    return MangaMiscScreenState(
      config: config ?? this.config,
    );
  }

  @override
  List<Object?> get props => [config];
}
