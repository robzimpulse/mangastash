import 'package:equatable/equatable.dart';

import '../database/database.dart';

class MangaModel extends Equatable {
  final MangaDrift? manga;
  final List<TagDrift> tags;

  const MangaModel({this.manga, this.tags = const []});

  @override
  List<Object?> get props => [manga, tags];
}
