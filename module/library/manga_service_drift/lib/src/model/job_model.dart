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
}
