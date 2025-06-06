import 'package:equatable/equatable.dart';

import '../database/database.dart';
import 'chapter_model.dart';

class MangaModel extends Equatable {
  final MangaDrift? manga;
  final List<TagDrift> tags;
  final List<ChapterModel> chapters;

  const MangaModel({
    this.manga,
    this.tags = const [],
    this.chapters = const [],
  });

  @override
  List<Object?> get props => [manga, tags, chapters];
}