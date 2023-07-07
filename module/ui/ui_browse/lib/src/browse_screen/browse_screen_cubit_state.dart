import 'package:equatable/equatable.dart';

class BrowseScreenCubitState extends Equatable {

  final List<MangaSource> sources;

  const BrowseScreenCubitState({required this.sources});

  @override
  List<Object?> get props => [sources];

}

// TODO: move `MangaSource` to entity
class MangaSource extends Equatable {

  final String name;

  final String url;

  const MangaSource({required this.name, required this.url});

  @override
  List<Object?> get props => [name, url];
}