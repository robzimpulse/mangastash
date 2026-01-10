import 'package:equatable/equatable.dart';

import '../database/database.dart';

class OrphanMangaModel extends Equatable {
  final MangaDrift? manga;
  final TagDrift? tag;

  const OrphanMangaModel({
    this.manga,
    this.tag,
  });

  @override
  List<Object?> get props => [manga, tag];
}