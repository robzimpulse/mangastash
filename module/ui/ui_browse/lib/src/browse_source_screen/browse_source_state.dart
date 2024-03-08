import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class BrowseSourceState extends Equatable with EquatableMixin {
  final List<MangaSource> sources;
  final bool isLoading;

  const BrowseSourceState({
    required this.sources,
    required this.isLoading,
  });

  @override
  List<Object?> get props => [sources, isLoading];

  BrowseSourceState copyWith({
    List<MangaSource>? sources,
    bool? isLoading,
  }) {
    return BrowseSourceState(
      isLoading: isLoading ?? this.isLoading,
      sources: sources ?? this.sources,
    );
  }
}
