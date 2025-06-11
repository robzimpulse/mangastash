import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class MangaMiscScreenState extends Equatable {

  final ChapterConfig? config;

  const MangaMiscScreenState({
    this.config,
  });

  MangaMiscScreenState copyWith({
    ChapterConfig? config,
  }) {
    return MangaMiscScreenState(
      config: config ?? this.config,
    );
  }

  @override
  List<Object?> get props => [config];
}
