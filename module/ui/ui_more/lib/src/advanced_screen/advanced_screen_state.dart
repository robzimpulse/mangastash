import 'package:core_storage/core_storage.dart';
import 'package:equatable/equatable.dart';

class AdvancedScreenState extends Equatable {
  const AdvancedScreenState({
    this.duplicatedManga = const {},
    this.duplicatedChapter = const {},
    this.duplicatedTag = const {},
    this.orphanedChapter = const [],
  });

  final DuplicatedResult<MangaDrift> duplicatedManga;
  final DuplicatedResult<ChapterDrift> duplicatedChapter;
  final DuplicatedResult<TagDrift> duplicatedTag;
  final List<ChapterDrift> orphanedChapter;

  @override
  List<Object?> get props => [
    duplicatedManga,
    duplicatedChapter,
    duplicatedTag,
    orphanedChapter,
  ];

  AdvancedScreenState copyWith({
    DuplicatedResult<MangaDrift>? duplicatedManga,
    DuplicatedResult<ChapterDrift>? duplicatedChapter,
    DuplicatedResult<TagDrift>? duplicatedTag,
    List<ChapterDrift>? orphanedChapter,
  }) {
    return AdvancedScreenState(
      duplicatedManga: duplicatedManga ?? this.duplicatedManga,
      duplicatedChapter: duplicatedChapter ?? this.duplicatedChapter,
      duplicatedTag: duplicatedTag ?? this.duplicatedTag,
      orphanedChapter: orphanedChapter ?? this.orphanedChapter,
    );
  }
}
