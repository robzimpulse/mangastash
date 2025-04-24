import 'package:equatable/equatable.dart';
import 'package:ui_common/ui_common.dart';

class BrowseSourceScreenState extends Equatable {
  final List<MangaSource> sources;

  const BrowseSourceScreenState({
    this.sources = const [],
  });

  @override
  List<Object?> get props => [sources];

  BrowseSourceScreenState copyWith({
    List<MangaSource>? sources,
  }) {
    return BrowseSourceScreenState(
      sources: sources ?? this.sources,
    );
  }
}
