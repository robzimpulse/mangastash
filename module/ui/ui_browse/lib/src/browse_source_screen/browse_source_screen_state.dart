import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class BrowseSourceScreenState extends Equatable with EquatableMixin {
  final List<MangaSource> sources;

  const BrowseSourceScreenState({required this.sources});

  @override
  List<Object?> get props => [sources];
}
