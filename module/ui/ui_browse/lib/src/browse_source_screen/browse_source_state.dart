import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class BrowseSourceState extends Equatable with EquatableMixin {
  final List<MangaSource> sources;
  final bool isLoading;
  final Exception? error;

  const BrowseSourceState({
    required this.sources,
    required this.isLoading,
    this.error,
  });

  @override
  List<Object?> get props => [sources, isLoading, error];

  BrowseSourceState copyWith({
    List<MangaSource>? sources,
    bool? isLoading,
    Exception? error,
  }) {
    return BrowseSourceState(
      isLoading: isLoading ?? this.isLoading,
      sources: sources ?? this.sources,
      error: error ?? this.error,
    );
  }
}
