import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:equatable/equatable.dart';

class BrowseSourceScreenState extends Equatable {
  final List<SourceExternal> sources;

  const BrowseSourceScreenState({
    this.sources = const [],
  });

  @override
  List<Object?> get props => [sources];

  BrowseSourceScreenState copyWith({
    List<SourceExternal>? sources,
  }) {
    return BrowseSourceScreenState(
      sources: sources ?? this.sources,
    );
  }
}
