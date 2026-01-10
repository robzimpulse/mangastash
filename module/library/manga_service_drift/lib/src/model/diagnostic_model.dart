import 'package:equatable/equatable.dart';

import '../database/database.dart';
import 'manga_model.dart';

class DiagnosticModel extends Equatable {
  const DiagnosticModel({
    this.mangaTagRelationship,
    this.manga,
    this.tag,

    this.duplicatedManga,
  });

  final RelationshipTable? mangaTagRelationship;
  final MangaDrift? manga;
  final TagDrift? tag;

  final MapEntry<(String?, String?), List<MangaModel>>? duplicatedManga;

  @override
  List<Object?> get props => [
    manga,
    tag,
    mangaTagRelationship,
    duplicatedManga,
  ];
}
