import 'package:entity_manga/entity_manga.dart';
import 'package:equatable/equatable.dart';

class BrowseSourceScreenCubitState extends Equatable with EquatableMixin {
  final List<MangaSource> sources;

  const BrowseSourceScreenCubitState({required this.sources});

  @override
  List<Object?> get props => [sources];
}
