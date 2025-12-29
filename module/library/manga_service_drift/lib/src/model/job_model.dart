import 'package:equatable/equatable.dart';

import '../database/database.dart';
import '../util/job_type_enum.dart';

class JobModel extends Equatable {
  final int id;
  final JobTypeEnum type;
  final String? image;
  final String? path;

  final MangaDrift? manga;
  final ChapterDrift? chapter;

  const JobModel({
    required this.id,
    required this.type,
    this.manga,
    this.chapter,
    this.image,
    this.path,
  });

  @override
  List<Object?> get props => [id, type, manga, chapter, image, path];

  Map<String, dynamic> toExtra() {
    final source = manga?.source;
    final mangaTitle = manga?.title;
    final chapterTitle = chapter?.title;
    final image = this.image;
    final path = this.path;

    return {
      'id': id,
      'type': type.name,
      if (source != null && source.isNotEmpty) 'manga_source': source,
      if (mangaTitle != null && mangaTitle.isNotEmpty)
        'manga_title': mangaTitle,
      if (chapterTitle != null && chapterTitle.isNotEmpty)
        'chapter_title': chapterTitle,
      if (image != null && image.isNotEmpty) 'image': image,
      if (path != null && path.isNotEmpty) 'path': path,
    };
  }
}
