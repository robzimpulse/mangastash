import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class BrowseSourceState extends Equatable with EquatableMixin {
  final List<MangaSource> sources;

  const BrowseSourceState({required this.sources});

  @override
  List<Object?> get props => [sources];
}
