import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class BrowseSourceScreenState extends Equatable {
  final List<SourceEnum> sources;

  const BrowseSourceScreenState({
    this.sources = const [],
  });

  @override
  List<Object?> get props => [sources];

  BrowseSourceScreenState copyWith({
    List<SourceEnum>? sources,
  }) {
    return BrowseSourceScreenState(
      sources: sources ?? this.sources,
    );
  }
}
