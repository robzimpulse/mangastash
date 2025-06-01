import 'package:equatable/equatable.dart';

import '../database/database.dart';
import '../util/job_type_enum.dart';

class JobDetail extends Equatable {
  final int id;
  final JobTypeEnum type;

  final MangaDrift? manga;
  final ChapterDrift? chapter;
  final String? image;

  const JobDetail({
    required this.id,
    required this.type,
    this.manga,
    this.chapter,
    this.image,
  });

  @override
  List<Object?> get props => [id, type, manga, chapter, image];
}
