import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class BrowseScreenCubitState extends Equatable with EquatableMixin {
  final List<MangaSource> sources;

  const BrowseScreenCubitState({required this.sources});

  @override
  List<Object?> get props => [sources];
}
