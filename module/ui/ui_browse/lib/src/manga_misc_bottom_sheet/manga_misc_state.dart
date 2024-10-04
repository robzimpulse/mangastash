import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaMiscState extends Equatable {

  final MangaChapterConfig? config;

  const MangaMiscState({
    this.config,
  });

  MangaMiscState copyWith({
    MangaChapterConfig? config,
  }) {
    return MangaMiscState(
      config: config ?? this.config,
    );
  }

  @override
  List<Object?> get props => [config];
}
