import 'package:equatable/equatable.dart';

import '../database/database.dart';

class DiagnosticModel extends Equatable {
  const DiagnosticModel({
    this.duplicatedManga = const {},
    this.duplicatedChapter = const {},
    this.duplicatedTag = const {},
  });

  final Map<(String?, String?), List<MangaDrift>> duplicatedManga;
  final Map<(String?, String?), List<TagDrift>> duplicatedTag;
  final Map<(String?, String?), List<ChapterDrift>> duplicatedChapter;

  @override
  List<Object?> get props => [
    duplicatedManga,
    duplicatedChapter,
    duplicatedTag,
  ];
}
